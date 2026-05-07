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
    allowed_ext_name: str = "base"   # worker 端单例初始化
    bug_filter_arch: str = "xs"      # worker 端单例初始化
```

### 2.3 WorkerResult — worker 返回的观测数据

精简设计，仅包含主进程评估需要的字段（`ExecuteResult` 现有 19 个字段中仅 6 个被活跃使用，其余 13 个为死字段）：

```python
@dataclass
class WorkerResult:
    seed_id: str
    img_path: str
    status: str               # CaseStatus 枚举值
    exit_code: int
    duration_s: float
    failure_kind: str | None  # FailureKind 枚举值
    message: str
    transitions: list[dict]   # CSR 转移列表 (observation.py 解析)
    diff_families: list[str]  # diff 族标签
```

sync 判定（`syncable_count` / `potential_bug_count`）不在 worker 内计算，保留给主进程的 `SyncDecisionEngine`。

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

分阶段处理：先用 `FeedbackSignalExtractor.extract()` 获取 `exploration_value`，再用 `FitnessCalculator.evaluate()` 计算持久化的 `SeedFitness`，最后用 `FeedbackDecisionPolicy.decide()` 决策。

```python
# Step 1: 基于 snapshot 的覆盖 delta（粗粒度 coverage key）
delta = corpus.preview_delta_from_snapshot(snapshot, result.transitions)

# Step 2: sync 判定
sync_summary = sync_engine.summary(
    sync_engine.classify([{"family": f, "cov": ""} for f in result.diff_families])
)

# Step 3: diff 新颖度（细粒度：区分全新族 vs 已见族）
diff_delta = corpus.preview_diff_delta(result.diff_families)
diff_novelty = len(diff_delta["new_families"]) / max(len(set(result.diff_families)), 1) \
              if result.diff_families else 0.0

# Step 4: 信号提取（category_deltas 来自 snapshot, rarity 来自 live corpus）
signals = signal_extractor.extract(
    status=result.status,
    failure_kind=result.failure_kind,
    coverage_new_points=delta["new_coverage"],
    coverage_total_points=delta["total_coverage"],
    category_deltas=delta["by_category"],
    transition_rarities=corpus.get_category_rarities(),  # 本次设计首次启用
    diff_novelty_score=diff_novelty,
    syncable_count=sync_summary["syncable_count"],
)

# Step 5: 适应度计算（激活现有 FitnessCalculator）
parent_fitness = corpus.get_seed_fitness(task.seed_ref.lineage_parent or "")
fitness = FitnessCalculator.evaluate(
    category_deltas=delta["by_category"],
    diff_families=result.diff_families,
    exploration_score=signals.exploration_value,
    lineage_parent=parent_fitness,
)
corpus.update_seed_fitness(result.seed_id, fitness)

# Step 6: 种子分数 = exploration_value（用于 scheduler 队列排序）
score = fitness.exploration_score

# Step 7: 决策
decision = decision_policy.decide(signals)
```

**FitnessCalculator 激活理由**（此前为零调用点死代码）：
- `category_affinity` 记录种子对各 CSR 类别的贡献比例 → `GoalDirectedScheduler.tag_seed()` 可据此标记种子类别
- `lineage_depth` 追踪血统代数 → 深层种子说明变异链有效，应优先
- `novelty_score` 和 `diff_diversity` 持久化到 `campaign_state.json`，跨运行可追踪

### 5.5 feedback_loop.py 加固

`extract()` 方法当前第 54-57 行直接访问 `delta["total"]` / `delta["new"]`，若数据结构异常会抛 `KeyError`。加固为：

```python
# Before:
if delta["total"] > 0:
    rarity = (transition_rarities or {}).get(cat, 1.0)
    exploration_value += weight * rarity * (delta["new"] / float(delta["total"]))

# After:
if delta.get("total", 0) > 0:
    rarity = (transition_rarities or {}).get(cat, 1.0)
    exploration_value += weight * rarity * (delta.get("new", 0) / float(delta["total"]))
```

### 5.6 RunCorpus 新增方法

- `snapshot() -> set[str]` — 返回 `_seen_coverage_points.copy()`
- `preview_delta_from_snapshot(snapshot: set[str], transitions: list[dict]) -> dict` — 用 `make_coverage_key()` 转换 transitions 为粗粒度 key，对比 snapshot（而非 `_seen_transitions`）计算 delta。返回 `{"new_coverage": N, "total_coverage": N, "by_category": {"privilege": {"new": 2, "total": 3}, ...}}`
- `get_category_rarities() -> dict[str, float]` — 遍历 `_transition_frequency`，按 key 首段（类别名）分组，取每类别 transition 稀有度均值。返回 `{"privilege": 0.72, "float": 0.85, ...}`

### 5.7 build_bundle() 规范：显式使用 CaseStatus 枚举

当前 `dut_executor.py:372-377` 用裸字符串映射 status（`"executed"`, `"diff_failed"` 等），绕过了 `CaseStatus` 枚举。本次改造中 `build_bundle()` 显式使用枚举：

```python
def build_bundle(seed_ref: SeedRef, result: WorkerResult,
                 execute_result: ExecuteResult) -> dict:
    status_str = result.status  # 已是 CaseStatus 枚举值
    return {
        "case_id": result.seed_id,  # seed_id 即 case_id
        "seed": seed_ref.seed_id,
        "lineage_parent": seed_ref.lineage_parent,
        "status": status_str,
        "coverage_result": {"points": {...}, "status": "collected"},
        "execute_result": execute_result,
        "feedback_decision": None,  # 由 5d 决策后填充
    }
```

`WorkerResult.status` / `WorkerResult.failure_kind` 在 worker 内也使用枚举值，避免字符串拼写错误。

### 5.8 Transition 全量持久化

`dump_campaign_state()` 当前只保存频率 top 1000 的 transition key（`transition_frequency_sample`），低频 transition 在恢复时丢失。本次修改追加 `"transition_keys_full"` 字段，保存完整 `_seen_transitions` 集合，消除有损恢复。

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

### 6.2 无状态设计 + Worker 端单例初始化

`worker_generate()` / `worker_mutate()` / `worker_execute()` 全部显式参数，不依赖 `_divefuzz_config` 全局变量。

但 generator 内部有两个模块级单例（`allowed_ext`、`bug_filter`），由 `setup_config()` 在主进程设置。在 Linux `fork` 模式下子进程继承这些单例，但在 `spawn` 模式下会丢失。`worker_entry()` 启动时显式调用一次轻量初始化以确保兼容性：

```python
def _setup_worker_singletons(allowed_ext_name: str, architecture: str):
    """Initialize generator module-level singletons inside worker process."""
    from generator.asm_template_manager.ext_list import allowed_ext
    from generator.bug_filter import bug_filter
    allowed_ext.setup_ext(allowed_ext_name)
    bug_filter.set_architecture(architecture)
```

`WorkerTask` 新增两个字段：`allowed_ext_name: str`、`bug_filter_arch: str`（纯字符串，pickle 安全）。

`arch`（ArchConfig）是 picklable dataclass，可安全跨进程传递。

### 6.3 Observe 文件隔离与清理

每个种子独立路径：`difftest.observe.{seed_id}.jsonl`，避免多 worker 并发写入冲突。

worker 解析 observation 后立即删除 observe 文件（数据已提取到 WorkerResult），避免磁盘膨胀。

### 6.4 worker_generate 优化：绕开嵌套线程池

`process_assembly_files()`（`elf_to_img.py:80`）内部用 `ThreadPoolExecutor` 并行编译所有 `.S` 文件。当 `seed_times=1`（每 worker 只生成 1 个种子）时，嵌套线程池是浪费。`worker_generate()` 直接调用底层的 `process_file(seed_file, output_dir, img_dir, elf_dir)` 替代，消除不必要的线程创建。

---

## 7. 持久化与容错

### 7.1 保存内容

**campaign_state.json**（已有 dump_campaign_state，增强）：

```json
{
  "coverage_points": ["control|csrrs", "privilege|csrrw"],
  "transition_keys": {"privilege|...|csrrs:0x342": 3},
  "transition_keys_full": ["privilege|...|csrrs:0x342", "float|...|fadd.s:0x53", ...],
  "diff_family_counts": {"fp_rounding": 2},
  "seed_fitness": {"000001": {"exploration_score": 0.8, "category_affinity": {...}, ...}},
  "signatures": ["exec|executed|none|..."],
  "last_seed_id": 42,
  "total_iterations": 150
}
```

- `transition_keys`（频率 top 1000）保留用于快速预览和调试
- `transition_keys_full`（新增）保存完整 `_seen_transitions` 集合，消除跨运行有损恢复
- `seed_fitness` 首次在运行时被 `FitnessCalculator` 填充（此前只在 bootstrap 时反序列化）

**queue_state.json**（新增）：

```json
{
  "bug_proximity": [{"seed_id": "000007", "score": 0.95, "lineage": "000003"}],
  "stable_ancestor": [{"seed_id": "000012", "score": 0.72, "lineage": "000005"}],
  "exploration": [{"seed_id": "000020", "score": 0.45, "lineage": "000018"}]
}
```

### 7.1.1 serde.py 补齐 load_json

当前 `serde.py` 只有 `dump_json()`（只写不读）。新增 `load_json(path: Path) -> Any` 统一 JSON 反序列化入口。`campaign_state.json` 和 `queue_state.json` 的加载均通过此函数。

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
| `fuzzer/core/corpus.py` | **修改** | 新增 snapshot(), preview_delta_from_snapshot(), get_category_rarities(); dump_campaign_state 追加 transition_keys_full |
| `fuzzer/core/fitness.py` | **修改** | 激活 FitnessCalculator（5d 打分时调用 evaluate + update_lineage） |
| `fuzzer/core/feedback_loop.py` | **修改** | extract() 加固 .get() 防御 KeyError |
| `fuzzer/utils/serde.py` | **修改** | 新增 load_json() |
| `fuzzer/executor/worker.py` | **新建** | worker_entry(), _setup_worker_singletons(), worker_generate(), worker_mutate(), worker_execute() |
| `fuzzer/executor/dut_executor.py` | **修改** | _run_dut_tests_with_feedback() → Manager-Worker 调度循环; build_bundle() 用 CaseStatus 枚举 |
| `fuzzer/run_dut.py` | **修改** | 加载 queue_state.json; 保存 scheduler dump; 传递完整参数给 WorkerTask |
| `fuzzer/tests/test_feedback_loop.py` | **更新** | ScheduledSeed → SeedRef 适配; 新增 pop_best、snapshot delta、FitnessCalculator 测试 |

### 不变部分

- `generator/` 目录完全不碰（worker 函数通过现有公开 API 调用）
- `run_divefuzz()` / `run_divefuzz_single()` 不删除（向后兼容）
- `sync.py`、`observation.py` 逻辑不变
- `config/` 结构不变

---

## 9. 实现步骤

1. `seed_ref.py` — 三个 dataclass，纯数据，无依赖
2. `scheduler.py` — ScheduledSeed → SeedRef, heapq, pop_best, dump/restore
3. `corpus.py` — 新增 snapshot(), preview_delta_from_snapshot(), get_category_rarities(); dump_campaign_state 追加 transition_keys_full
4. `feedback_loop.py` — extract() 加固 .get()
5. `fitness.py` — 确保 FitnessCalculator.evaluate() 对接新数据流
6. `serde.py` — 新增 load_json()
7. `worker.py` — 从 divefuzz_adapter.py 抽取无状态 worker 函数 + 单例初始化 + process_file 直调
8. `dut_executor.py` — 新调度循环 + build_bundle() CaseStatus 枚举化
9. `run_dut.py` — 加载/保存 queue_state，传参适配
10. 测试更新 — 适配新类型，新增 pop_best、snapshot delta、FitnessCalculator 测试
