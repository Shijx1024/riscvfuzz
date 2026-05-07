# Multi-Process Feedback Loop Design

> 2026-05-07 — RVFUZZ 反馈回路适配 DiveFuzz 多进程设计

## 1. 架构总览

当前单进程回路：

```
while index < batch_size:
    seed = scheduler.pop_next()     → generate → execute → observe
                                   → extract signals → decide → record → mutate
```

改为 **Manager-Worker 批量模式**（融入 DiveFuzz 原生 ProcessPoolExecutor 范式）：

```
Main Process (Manager):                    Worker Pool (M processes):
  while iter < batch_size:
    snapshot = corpus.snapshot()
    batch = scheduler.pop_best(M)  ──→   worker-0: gen/mutate → exec → observe
                                         worker-1: gen/mutate → exec → observe
    results = gather(workers)      ←──   ...
    for r in results:
      score = compute(r, snapshot)         # 快照隔离，公平打分
    for r in results:
      corpus.record(r)                    # 集中更新全局 corpus
    for r in results:
      scheduler.push(scored_ref)          # 种子重新入队
    persist()                             # 每 batch 持久化
```

**关键设计决策**：
- corpus/scheduler/decision 只在主进程 — 无锁、无竞争
- worker 只做纯计算 — 接收参数 → gen/mutate → exec → parse → 返回原始数据
- snapshot 隔离打分 — batch 内所有种子基于同一基线评分
- M = `dut_config.threads` — 复用 DiveFuzz 已有配置
- 变异异步入队 — 不阻塞当前 batch dispatch

---

## 2. 数据模型

### 2.1 SeedRef — 队列元素（替换 ScheduledSeed）

```python
@dataclass
class SeedRef:
    seed_id: str              # "000042"，对应 seeds/000042/seed_0.img
    queue: str                # "bug_proximity" | "stable_ancestor" | "exploration"
    score: float = 0.0        # 优先级分数（heapq 排序）
    lineage_parent: str | None = None
    action: str = "generate"  # "generate" | "mutate"
```

### 2.2 WorkerTask — dispatch 给 worker 的完整上下文

```python
@dataclass
class WorkerTask:
    seed_ref: SeedRef
    output_dir: Path           # corpus_dir / "seeds"
    emu_cmd: str              # DUT 仿真命令模板
    emu_path: str             # DUT 工作目录
    arch: ArchConfig          # picklable dataclass
    instr_number: int = 200
    template_type: str = "rocket"
    architecture: str = "rkt"
    dive_enable: bool = True
    is_rv32: bool = False
```

### 2.3 WorkerResult — worker 返回的观测数据

```python
@dataclass
class WorkerResult:
    seed_id: str
    img_path: str
    status: str               # "executed" | "diff_failed" | "timeout" | "infra_error"
    failure_kind: str | None
    message: str
    exit_code: int
    duration_s: float
    transitions: list[dict]   # CSR 转移列表
    diff_families: list[str]  # diff 族标签
```

---

## 3. 种子存储

统一目录结构：

```
corpus_dir/
  seeds/
    000001/
      seed_0.img          ← 可执行程序
    000042/
      seed_0.img
    ...
  campaign_state.json     ← 全局覆盖状态（已有，增强）
  queue_state.json         ← 队列快照（新增）
```

- `seed_id` 六位递增分配，`last_seed_id` 记录在 campaign_state.json
- worker 按约定路径拼接：`{output_dir}/{seed_id}/seed_0.img`
- 队列里只存 `seed_id`，不存完整路径

---

## 4. 调度器重构

### 4.1 三队列 + 批量概率出队

```
优先级权重:
  bug_proximity:     50%
  stable_ancestor:   30%
  exploration:       20%
```

`pop_best(M)`: 按权重从三队列 heapq 各取分数最高的 N 个。

### 4.2 队列数据结构

三队列 deque → 三队列 heapq（按 `score` 降序）：
- `bug_proximity` 队列不按分数排序（bug 候选同等重要，FIFO）
- `stable_ancestor`、`exploration` 按 score 排序

### 4.3 GoalDirectedScheduler 保留

饱和度 boost 逻辑保留：低饱和度类别（< 0.3）的种子在 `pop_best` 时获得临时分数加成，被优先选中。

---

## 5. 调度循环

```
Main Process:

1. setup_divefuzz()              ← 一劳永逸，产出 ArchConfig
2. 加载 campaign_state.json + queue_state.json
3. 恢复 corpus + scheduler 状态

4. if scheduler empty:
     warmup: 主进程分配 M 个新 seed_id，生成 WorkerTask(action="generate")
     → dispatch 给 worker pool 执行 → 按 snapshot 打分 → 入队

5. while iter < batch_size and scheduler not empty:
     # 5a. 快照当前 corpus
     snapshot = corpus.snapshot()

     # 5b. 取出 M 个种子
     if len(scheduler) < M:
         生成 (M - len(scheduler)) 个新鲜种子并入队
     batch = scheduler.pop_best(M)

     # 5c. Dispatch 给 worker
     tasks = [WorkerTask(ref, ...) for ref in batch]
     results = pool.map(worker_entry, tasks)

     # 5d. 第一遍：基于 snapshot 公平打分 + 暂存决策
     for task, result in zip(batch, results):
         delta = corpus.preview_delta_from_snapshot(snapshot, result.transitions)
         sync_summary = sync_engine.summary(
             sync_engine.classify([{"family": f, "cov": ""} for f in result.diff_families])
         )
         signals = signal_extractor.extract(
             status=result.status,
             failure_kind=result.failure_kind,
             coverage_new_points=delta["new_coverage"],
             coverage_total_points=delta["total_coverage"],
             category_deltas=delta["by_category"],
             transition_rarities=corpus.get_category_rarities(),
             diff_novelty_score=(1.0 if result.diff_families else 0.0),
             syncable_count=sync_summary["syncable_count"],
         )
         task._score = signals.exploration_value
         task._decision = decision_policy.decide(signals)

     # 5e. 第二遍：更新全局 corpus（顺序无关排序，所有结果都记录）
     for task, result in zip(batch, results):
         corpus.record_transitions(result.transitions)
         if result.diff_families:
             corpus.record_diff_families(result.diff_families, result.seed_id)
         scheduler.update_saturation(delta["by_category"])
         bundle = build_bundle(task.seed_ref, result)
         corpus.record(bundle)

     # 5f. 第三遍：按决策入队
     for task, result in zip(batch, results):
         score = task._score
         decision = task._decision
         if decision.decision == "promote_mutation":
             scheduler.push(SeedRef(task.seed_ref.seed_id, decision.queue,
                                    score, lineage_parent=task.seed_ref.seed_id,
                                    action=task.seed_ref.action))
             # 变异种子入队（action="mutate", lineage=原种子）
             # 分配新 seed_id，下次 batch dispatch 时 worker 调 worker_mutate() 执行
             mutated_id = allocate_seed_id()
             scheduler.push(SeedRef(mutated_id, "stable_ancestor",
                                    score, lineage_parent=task.seed_ref.seed_id,
                                    action="mutate"))
         elif decision.decision == "keep_in_corpus":
             scheduler.push(SeedRef(task.seed_ref.seed_id, "exploration",
                                    score, lineage_parent=task.seed_ref.seed_id,
                                    action=task.seed_ref.action))
         # archive_only / discard → 不入队

     # 5g. 持久化
     corpus.dump_campaign_state()
     scheduler.dump_queue_state()
     iter += 1
```

### 5.4 分数计算与决策

复用现有 `FeedbackSignalExtractor.extract()` + `FeedbackDecisionPolicy.decide()` 两步，关键差异是 delta 来自 snapshot 而非 live corpus：

```python
# Step 1: 基于 snapshot 的覆盖 delta（粗粒度 coverage key）
delta = corpus.preview_delta_from_snapshot(snapshot, result.transitions)

# Step 2: sync 判定
sync_summary = sync_engine.summary(
    sync_engine.classify([{"family": f, "cov": ""} for f in result.diff_families])
)

# Step 3: 信号提取（category_deltas 来自 snapshot, rarity 来自 live corpus）
signals = signal_extractor.extract(
    status=result.status,
    failure_kind=result.failure_kind,
    coverage_new_points=delta["new_coverage"],
    coverage_total_points=delta["total_coverage"],
    category_deltas=delta["by_category"],
    transition_rarities=corpus.get_category_rarities(),   # ← 新增：按类别聚合稀有度
    diff_novelty_score=(1.0 if result.diff_families else 0.0),
    syncable_count=sync_summary["syncable_count"],
)
score = signals.exploration_value

# Step 4: 决策
decision = decision_policy.decide(signals)
# → promote_mutation (bug_proximity / stable_ancestor)
# → keep_in_corpus (exploration)
# → archive_only / discard (不入队)
```

`transition_rarities` 参数（之前在所有调用点均为 None）首次被启用：`get_category_rarities()` 按类别聚合 transition 频率，低频类别稀有度更高 → 产生该类覆盖的种子得到更高 `exploration_value`。

### 5.5 RunCorpus 新增方法

- `snapshot() -> set[str]` — 返回 `_seen_coverage_points.copy()`
- `preview_delta_from_snapshot(snapshot: set[str], transitions: list[dict]) -> dict` — 用 `make_coverage_key()` 转换 transitions 为粗粒度 key，对比 snapshot（而非 `_seen_transitions`）计算 delta。返回 `{"new_coverage": N, "total_coverage": N, "by_category": {"privilege": {"new": 2, "total": 3}, ...}}`
- `get_category_rarities() -> dict[str, float]` — 遍历 `_transition_frequency`，按 key 首段（类别名）分组，取每类别 transition 稀有度均值。返回 `{"privilege": 0.72, "float": 0.85, ...}`

---

## 6. Worker 接口

### 6.1 worker_entry

```python
def worker_entry(task: WorkerTask) -> WorkerResult:
    # 1. 生成或变异
    if task.seed_ref.action == "generate":
        img_path = worker_generate(
            seed_id=task.seed_ref.seed_id,
            output_dir=task.output_dir,
            arch=task.arch,
            instr_number=task.instr_number,
            template_type=task.template_type,
            architecture=task.architecture,
            dive_enable=task.dive_enable,
            is_rv32=task.is_rv32,
        )
    else:
        parent_img = seed_path(task.output_dir, task.seed_ref.lineage_parent)
        img_path = worker_mutate(
            seed_id=task.seed_ref.seed_id,
            parent_img=parent_img,
            output_dir=task.output_dir,
            arch=task.arch,
            dive_enable=task.dive_enable,
            is_rv32=task.is_rv32,
            template_type=task.template_type,
            architecture=task.architecture,
        )

    # 2. 执行
    exec_result = worker_execute(
        img_path=img_path,
        seed_id=task.seed_ref.seed_id,
        emu_cmd=task.emu_cmd,
        emu_path=task.emu_path,
    )

    # 3. 解析 observation
    obs = parse_observation(exec_result.observation_path)

    return WorkerResult(
        seed_id=task.seed_ref.seed_id,
        img_path=str(img_path),
        status=exec_result.status,
        transitions=obs.transitions,
        diff_families=obs.diff_families,
        ...
    )
```

### 6.2 无状态设计

`worker_generate()` / `worker_mutate()` / `worker_execute()` 全部显式参数，无隐式全局状态依赖（不读 `_divefuzz_config` 全局变量）。

`arch`（ArchConfig）是 picklable dataclass，可安全跨进程传递。

### 6.3 Observe 文件隔离

每个种子独立路径：`difftest.observe.{seed_id}.jsonl`，避免多 worker 并发写入冲突。

---

## 7. 持久化与容错

### 7.1 保存内容

**campaign_state.json**（已有 dump_campaign_state，增强）：

```json
{
  "coverage_points": ["control|csrrs", "privilege|csrrw"],
  "transition_keys": {"privilege|...|csrrs:0x342": 3},
  "diff_family_counts": {"fp_rounding": 2},
  "seed_fitness": {"000001": {"exploration_score": 0.8}},
  "signatures": ["exec|executed|none|..."],
  "last_seed_id": 42,
  "total_iterations": 150
}
```

**queue_state.json**（新增）：

```json
{
  "bug_proximity": [{"seed_id": "000007", "score": 0.95, "lineage": "000003"}],
  "stable_ancestor": [{"seed_id": "000012", "score": 0.72, "lineage": "000005"}],
  "exploration": [{"seed_id": "000020", "score": 0.45, "lineage": "000018"}]
}
```

### 7.2 保存时机

每轮 batch 结束后统一写入（先写 .tmp → `os.replace()` 原子替换）。

### 7.3 恢复

```
启动时:
  1. corpus.bootstrap_from_campaign_state()
  2. scheduler.restore(queue_state.json)
  3. 遍历 seeds/ 目录: 有 img 文件但不在任何队列且未在 corpus 记录的种子
     → 创建 SeedRef(action="generate", score=0.5) 入 exploration 队尾
     → 下一轮执行后会按实际覆盖情况重新打分入队
  4. 队列空 → warmup 生成 M 个初始种子
```

### 7.4 容错

| 故障 | 处理 |
|------|------|
| Worker 超时 | `future.result(timeout=N)`, 标记 `status="timeout"` |
| Worker 崩溃 | `Future.set_exception` 捕获，seed_id 重新入 exploration 队尾 |
| 主进程崩溃 | 最新 batch 结果丢失，重启后从上一 batch checkpoint 继续 |
| 编译失败 | WorkerResult.status="generation_failed"，不入队 |

---

## 8. 文件变更清单

| 文件 | 动作 | 内容 |
|------|------|------|
| `fuzzer/core/seed_ref.py` | **新建** | SeedRef, WorkerTask, WorkerResult dataclass |
| `fuzzer/core/scheduler.py` | **修改** | ScheduledSeed → SeedRef; 三队列 deque → heapq; 新增 pop_best(); 新增 dump/restore |
| `fuzzer/executor/worker.py` | **新建** | worker_entry(), worker_generate(), worker_mutate(), worker_execute() |
| `fuzzer/executor/dut_executor.py` | **修改** | _run_dut_tests_with_feedback() → Manager-Worker 调度循环; 新增 evaluate_and_feedback() |
| `fuzzer/run_dut.py` | **修改** | 加载 queue_state.json; 保存 scheduler dump; 传递 emu_cmd/emu_path 给 WorkerTask |
| `fuzzer/tests/test_feedback_loop.py` | **更新** | ScheduledSeed → SeedRef 适配; 新增 pop_best 测试 |

### 不变部分

- `generator/` 目录完全不碰
- `run_divefuzz()` / `run_divefuzz_single()` 不删除（向后兼容）
- `observation.py`、`feedback_loop.py`、`sync.py`、`corpus.py`、`fitness.py` 逻辑不变
- `config/` 结构不变

---

## 9. 实现步骤

1. `seed_ref.py` — 三个 dataclass，纯数据，无依赖
2. `scheduler.py` — ScheduledSeed → SeedRef, heapq, pop_best, dump/restore
3. `worker.py` — 从 divefuzz_adapter.py 抽取无状态 worker 函数
4. `dut_executor.py` — 新调度循环替换 _run_dut_tests_with_feedback
5. `run_dut.py` — 加载/保存 queue_state，传参适配
6. 测试更新 — 适配新类型，新增 pop_best 测试
