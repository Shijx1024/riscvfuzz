# DiveFuzz Architecture Exploration Report

> 2026-05-06 — 为 RVFUZZ 反馈回路植入进行的全面架构分析
>
> **更新 2026-05-07** — 多进程 Manager-Worker 批量反馈回路, SeedRef/WorkerTask/WorkerResult 数据模型, heapq 调度器, snapshot 隔离打分, FitnessCalculator 激活

## 项目概览

DiveFuzz 是中科院信息工程研究所开发的 RISC-V CPU 差分模糊测试框架，支持 XiangShan、NutShell、Rocket、CVA6、BOOM 等多个 CPU 目标。

## 目录结构

```
learn/DiveFuzz/
  fuzzer/                  # 核心 fuzzer 代码
    run_dut.py             # 主入口 (YAML 驱动)
    config/                # 配置解析 (dut_config, divefuzz_config, logger_config)
    executor/              # DUT 测试执行
      dut_executor.py      # 调度循环 (Manager-Worker) + 原始批处理
      worker.py            # [RVFUZZ 新增] 无状态 worker 入口 (gen→exec→observe)
      divefuzz_adapter.py  # setup_divefuzz, run_divefuzz_single, run_divefuzz_mutate
    utils/                 # elf_to_img, results_reporter, serde
    generator/             # 指令生成与变异引擎 (原装未修改)
      main.py              # 独立生成器入口
      config/              # CLI 解析器, config_manager
      core/
        generator/         # generate_instrs.py, register_history.py, 并行分派
        mutator/           # mutate_instructions.py, modify_instr.py, data_collector.py
      instr_generator/     # 指令集定义, 格式模板, 变量范围
      reg_analyzer/        # SpikeSession, InstructionValidator, XORCache, HybridEncoder
      asm_template_manager/ # 汇编模板 (header/footer per CPU)
      bug_filter/          # 精度过滤器框架 (pre-execute + post-execute, 按架构注册)
    core/                  # [RVFUZZ 新增] 反馈回路组件
      seed_ref.py          # SeedRef, WorkerTask, WorkerResult dataclass
      status.py            # CaseStatus, FailureKind, ArtifactKind, RunStatus 枚举
      observation.py       # CSR 转移提取 + make_coverage_key + trivial CSR write 过滤
      sync.py              # SyncDecisionEngine (13 条同步/漏洞判定规则)
      scheduler.py         # MultiQueueScheduler + GoalDirectedScheduler (heapq + pop_best)
      feedback_loop.py     # FeedbackSignalExtractor + FeedbackDecisionPolicy
      corpus.py            # RunCorpus (snapshot, preview_delta_from_snapshot, get_category_rarities)
      fitness.py           # SeedFitness, FitnessCalculator (已激活, dominant_category)
    model/                 # [RVFUZZ 新增] 数据模型
      request.py           # MutationRequest (未使用, 死代码)
      result.py            # ExecuteResult dataclass
    tests/                 # [RVFUZZ 新增] 测试
      test_feedback_loop.py # 34 个集成测试 (10 个测试类)
  dut/                     # RTL 仿真器 (子模块)
    rocket-chip/           # Rocket Chip (Chisel RISC-V SoC)
  ref/                     # 参考模拟器 (子模块)
    riscv-isa-sim-adapter/ # 修改的 Spike + pybind11 checkpoint engine
  configs/                 # [RVFUZZ 新增] 反馈回路配置
    rocket_feedback.yaml   # Rocket + 反馈回路集成测试配置
  docs/
    divefuzz-architecture-exploration.md  # 本报告
    superpowers/specs/2026-05-07-multiprocess-feedback-loop-design.md
    superpowers/plans/2026-05-07-multiprocess-feedback-loop-plan.md
```

## 控制流

### 当前架构：双路径分派

`run_dut.py` 主入口自动初始化 RVFUZZ 反馈回路组件，通过 `run_dut_tests()` 分派到两条路径之一：

```
main()
  ├─ Config.from_yaml(args.config)
  ├─ [RVFUZZ P0] 初始化反馈组件:
  │    corpus = RunCorpus(max_retained=N)
  │    scheduler = GoalDirectedScheduler()
  │    signal_extractor = FeedbackSignalExtractor()
  │    decision_policy = FeedbackDecisionPolicy()
  ├─ [P0.1] 加载 campaign_state.json + queue_state.json (跨运行恢复)
  └─ run_dut_tests(config, config_filename, feedback={...})
       ├─ if feedback is not None:
       │    _run_dut_tests_with_feedback()  ← 默认路径 (Manager-Worker 批量回路)
       └─ else:
            _run_dut_tests_original()       ← 向后兼容 (原始批处理)
```

### 路径 A：Manager-Worker 批量反馈回路 (默认, `_run_dut_tests_with_feedback`)

```
run_dut.py
  ├─ setup_divefuzz() → 产出 ArchConfig
  ├─ warmup: if scheduler empty → 生成 M 个初始种子 → worker 执行 → 打分入队
  │
  └─ while iter < batch_size and scheduler not empty:
       ├─ snapshot = corpus.snapshot()           # 冻结当前覆盖点
       ├─ scheduler.pop_best(M)                  # 三队列加权出队 (50/30/20)
       │    └─ exploration/stable_ancestor: heapq 按 score; bug_proximity: FIFO
       ├─ pool.map(worker_entry, tasks)          # ProcessPoolExecutor 并行
       │    └─ worker_entry(task: WorkerTask) → WorkerResult
       │         ├─ action="generate" → worker_generate() → generate_instructions_parallel
       │         │    └─ process_file() 直调 (避免嵌套 ThreadPoolExecutor)
       │         ├─ action="mutate"    → worker_mutate()    → mutate_instructions_parallel
       │         ├─ worker_execute()   → subprocess.run(emu_cmd)
       │         │    └─ observe: difftest.observe.{seed_id}.jsonl (per-worker 隔离)
       │         └─ parse_observation() → 解析后删除 observe 文件
       │
       ├─ 第一遍 (snapshot 隔离打分):
       │    for each result:
       │      delta = corpus.preview_delta_from_snapshot(snapshot, transitions)
       │      signals = signal_extractor.extract(...)    # category_deltas + rarities
       │      fitness = fitness_calc.evaluate(...)       # 激活 FitnessCalculator
       │      decision = decision_policy.decide(signals)
       │
       ├─ 第二遍 (更新全局 corpus):
       │    for each result:
       │      corpus.record_transitions() + corpus.record_diff_families()
       │      scheduler.update_saturation() + scheduler.tag_seed()
       │      corpus.record(bundle)
       │
       ├─ 第三遍 (按决策入队):
       │    for each result:
       │      promote_mutation → push 原种子 + push 变异种子 (action="mutate")
       │      keep_in_corpus  → push 原种子 (exploration)
       │      archive_only    → 不入队
       │
       └─ persist: corpus.dump_campaign_state() + scheduler.dump_queue_state()
```

**关键设计决策**:
- corpus/scheduler/decision 只在主进程 — 无锁、无竞争
- snapshot 隔离打分 — batch 内所有种子基于同一基线
- M = `dut_config.threads` — 复用 DiveFuzz 已有配置
- 变异异步入队 — 不阻塞当前 batch dispatch
- observe 文件 per-seed 隔离, 解析后自动删除

### 路径 B：原始批处理 (向后兼容, `_run_dut_tests_original`)

```
main()
  └─ for each seed_config:
       run_single_test(dut_config, seed_config, ...)
         ├─ [GeneratedSeedConfig] setup_divefuzz() → run_divefuzz()
         │    ├─ generate_instructions_parallel() [mode=generate]
         │    │    └─ generate_instructions() × N (ProcessPoolExecutor)
         │    │         ├─ TemplateInstance (header/footer)
         │    │         ├─ SpikeSession (checkpoint engine)
         │    │         ├─ XORCache (Bloom filter 去重)
         │    │         ├─ InstructionValidator (Spike 验证)
         │    │         └─ write_instructions_to_file() → seeds_N.S
         │    ├─ mutate_instructions_parallel()  [mode=mutate]
         │    │    └─ process_content() × N
         │    │         ├─ classify_instructions() + Z-score 概率
         │    │         ├─ modify_instruction_inc/dec()
         │    │         └─ write_instructions_to_file() → *_mutated.S
         │    └─ process_divefuzz_asm()
         │         └─ .S → .o → .elf → .img (riscv64-unknown-elf-*)
         │
         └─ ThreadPoolExecutor: run_single_seed() × N
              └─ subprocess.run(emu_cmd, cwd=emu_path, timeout=300)
                   └─ TestResult(SUCCESS/FAILURE/TIMEOUT/ERROR)
```

---

## 核心机制

### 1. 指令生成 (`generate_instrs.py`)

```
while instr_count < target:
  1. 按概率选择扩展 (RV64_I, RV64_M, RV64_F, RV64_D, RV64_C, RV_V)
  2. 随机选择该扩展内的指令 opcode
  3. 从 RegisterHistory 选择寄存器 (LRU 队列, capacity=6)
  4. generate_new_instr() 生成完整指令 (含立即数, 10% 边界值)
  5. HybridEncoder 编码为机器码
  6. Spike 执行验证:
     a. 设置 checkpoint
     b. 执行指令
     c. 读回寄存器值
     d. XOR(src_values) → Bloom Filter 检查
     e. 唯一 → 确认; 重复 → 恢复 checkpoint, 换寄存器重试
  7. Bug Filter 检查 (两级: 预执行 + 后执行)
  8. nop 填充至模板对齐
```

### 2. XOR 去重 (DiveFuzz 核心创新)

- **XORCache**: 共享内存 Bloom Filter，检查 `(opcode, xor(src_register_values))` 是否已出现
  - 位于 `fuzzer/generator/reg_analyzer/xor_cache.py`
  - `compute_xor(values)` 对每个源寄存器**运行时值**做移位 XOR
  - `check_and_add(opcode, xor_value)` 查询 + 写入 Bloom Filter
- **StatefulXORCache**: 扩展为上下文感知
  - 覆盖: 浮点舍入模式 (frm)、向量状态 (vl/vsew/vflmul/vta/vma/vill)、特权级 (prv/v)、原子预留状态、内存上下文
  - `InstructionContext` 枚举映射指令类别到上下文类型
  - `compute_combined_hash()`: `((xor_value & 0xFFFFFFFF) << 32) | (context_hash & 0xFFFFFFFF)`
- **关键**: 使用 Spike **运行时寄存器值**做 XOR，不是寄存器编号。相同指令不同输入值产生不同 XOR 签名，实现更精准的去重。

### 3. 指令变异 (`mutate_instructions.py`)

```
1. 统计种子中每条指令的频率
2. Z-score 归一化 → 分类为 increase_queue / decrease_queue
3. increase_queue 指令: 以概率修改寄存器/立即数
4. decrease_queue 指令: 以概率替换为 NOP 或增加队列指令
5. 新扩展注入 (enable_ext)
6. Spike 验证每条变异指令
```

**已知限制**: 指令分布均匀时 (所有指令频率相同), Z-score = 0, 全部进 increase_queue, 修改逻辑产生空序列导致变异失败。需要足够复杂程序才能成功变异。

### 4. Bug Filter (`bug_filter/`)

```python
# 两级过滤 + 按架构注册
FilterRegistry:
  - pre_execute:  基于 opcode + 寄存器值 + CSR 状态 + 特权级预判
  - post_execute: 基于 Spike 执行后的 CSR 状态差异
  - 按架构注册: xs (XiangShan), nts (NutShell), boom (BOOM), cva6 (CVA6), rkt (Rocket)
  - FilterContext 懒加载: XPR, FPR, CSR, PC, privilege, virtualization, reservation, trap, vector
```

### 5. Spike Integration (`riscv-isa-sim-adapter/`)

```
spike_engine (C++ pybind11):
  ├─ checkpoint.cpp   → 高效 checkpoint save/restore
  ├─ state_query.cpp  → 寄存器/CSR/内存/向量状态读取
  ├─ bindings.cpp     → pybind11 模块导出
  └─ Makefile         → 链接 libspike.a
```

---

## RVFUZZ 反馈回路组件 (新增)

### 6. fuzzer/core/ 模块详解

#### 6.1 seed_ref.py — 数据模型

```python
SeedRef     # 队列元素 (seed_id, queue, score, lineage_parent, action)
WorkerTask  # dispatch 给 worker 的完整上下文 (含 arch, emu_cmd, 生成参数)
WorkerResult # worker 返回的观测数据 (status, transitions, diff_families)
```

`SeedRef` 替换了旧的 `ScheduledSeed`。`__lt__` 反转 heapq (min-heap → max-heap by score)。

#### 6.2 status.py — 状态枚举

```python
CaseStatus:  GENERATED | GENERATION_FAILED | INVALID_PROGRAM | EXECUTED |
            DIFF_FAILED | REFERENCE_FAILED | BADTRAP | TIMEOUT |
            INFRA_ERROR | COVERAGE_FAILED | ARCHIVED_NO_NOVELTY | SYNCABLE_NO_BUG

FailureKind: GENERATION_ERROR | INVALID_PROGRAM | BAD_TRAP | INFRA_ERROR |
             REFERENCE_ERROR | DIFF_MISMATCH | TIMEOUT | COVERAGE_COLLECTION_FAILED
```

#### 6.3 observation.py — CSR 转移 + Diff 族

**CSR 类别 (5+1):**

| 类别 | CSR 寄存器 | 权重 |
|------|-----------|------|
| privilege | mstatus, scause, mcause, medeleg, mideleg, sstatus | 1.0 |
| float | frm, fflags, fcsr | 0.8 |
| control | mepc, sepc, mtvec, stvec, mtval, stval, mscratch, sscratch | 0.9 |
| memory | satp, pmpcfg0-3, pmpaddr0-15 | 1.2 |
| counter | cycle, instret, mcycle, minstret, mcounteren, scounteren, mhpmevent3-31 | 0.5 |
| misc | (所有未在以上 5 类中的 CSR) | 0.3 |

**两层覆盖粒度**:
- **粗粒度 (覆盖点)**: `make_coverage_key()` → `"{category}|{mnemonic}"` — 用于 corpus 去重和 scheduler 打分
- **细粒度 (转移)**: `_serialize_transition()` → `"{csr}|{prev}|{curr}|{instr}"` — 用于稀有度追踪

**过滤**:
- `_parse_cov_field()`: 过滤 prev==curr (无变化) 和空值
- `_is_trivial_csr_write()`: 过滤 CSR 显式写指令 (csrrw/csrrs/csrrc 等) 对 privilege/float 类别的修改

**Diff 族 (7):**

| 族 | 描述 | 判定逻辑 |
|----|------|---------|
| fp_rounding | FP CSR changed, writeback difference <= 2 ulp | csr 为 fflags/frm/fcsr + 指令为 FP |
| fp_nan | FP register value NaN in one model | severity/message 含 "nan" |
| csr_write | CSR 值不匹配 (csrw/csrwi/csrs/csrc) | 指令为 CSR 写 |
| trap_difference | mcause/scause differs between ISA and RTL | payload 含 mcause/scause |
| pc_divergence | PC differs by > 4 bytes | payload 含 "pc" |
| memory_ordering | lr/sc/amo/fence 排序或预留不匹配 | 指令为原子/内存序 |
| unknown | 以上均不匹配 | 默认 |

#### 6.4 sync.py — 同步判定引擎

无状态 `SyncDecisionEngine`，`classify()` + `summary()`。13 条 syncable/potential_bug 规则。主进程多次调用安全。

#### 6.5 scheduler.py — 目标导向调度器

**MultiQueueScheduler** — 三队列 + 批量概率出队:

```
pop_best(M):
  bug_proximity:     50% (FIFO — bug 候选同等重要)
  stable_ancestor:   30% (heapq 按 score 降序)
  exploration:       20% (heapq 按 score 降序)
```

- `push(SeedRef)`: 去重 `_seen_seeds`; heapq 队列用 `heappush`
- `pop_best(M)`: 加权批量出队, 队列不足时返回部分结果
- `dump_queue(path)` / `restore(path)`: JSON 持久化, 跨运行恢复

**GoalDirectedScheduler** — 保留饱和度 boost:
- 低饱和度类别 (< 0.3) 的种子在扫描时优先弹出
- `tag_seed(seed_id, category)` 记录种子主导类别
- `update_saturation(category_deltas)` 更新饱和度

#### 6.6 feedback_loop.py — 信号提取 + 决策

**FeedbackSignalExtractor**:
- 按类别加权计算 `exploration_value = Σ(weight × rarity × new/total) / Σ(weight)`
- `transition_rarities` 参数已激活 (来自 `corpus.get_category_rarities()`)
- `extract()` 加固: `.get("total", 0)` / `.get("new", 0)` 防御 KeyError

**FeedbackDecisionPolicy**:
```
DIFF_FAILED / REFERENCE_FAILED / BADTRAP / TIMEOUT / COVERAGE_FAILED
  → promote_mutation (bug_proximity, score=1.0)

EXECUTED + coverage_new_points > 0
  → promote_mutation (stable_ancestor, score=max(0.1, exploration_value))

EXECUTED + 无新覆盖
  → keep_in_corpus (exploration, score=0.2)

其他 → discard (exploration, score=0.0)
```

#### 6.7 corpus.py — 运行语料库

`RunCorpus` 管理模糊测试运行中的种子多样性、去重和持久化：

- **去重**: `_seen_signatures`, `_seen_coverage_points` (粗粒度), `_seen_transitions` (细粒度)
- **新增方法**:
  - `snapshot()`: 返回 `_seen_coverage_points.copy()` — 快照隔离打分
  - `preview_delta_from_snapshot(snapshot, transitions)`: 对比快照计算覆盖 delta
  - `get_category_rarities()`: 按类别聚合 transition 稀有度均值
- **持久化**: `dump_campaign_state()` 追加 `transition_keys_full` 全量保存
- **恢复**: `bootstrap_from_campaign_state()` 从 `transition_keys_full` 完整恢复

#### 6.8 fitness.py — 种子适应度

**SeedFitness**: `{seed, category_affinity, novelty_score, diff_diversity, exploration_score, lineage_depth}`

**FitnessCalculator** (已激活):
- `evaluate()`: 计算类别亲和力、新颖性、diff 多样性、血统深度
- `dominant_category()`: 返回新增转移最多的 CSR 类别 — 用于 `GoalDirectedScheduler.tag_seed()`
- `update_lineage()`: 子代继承父代适应度 (EMA, α=0.3)

**MUTATION_STRATEGIES**: 定义但未使用 (死代码)

### 7. fuzzer/executor/ — 执行层

**dut_executor.py**:
- `_run_dut_tests_with_feedback()`: Manager-Worker 批量调度循环
- `_run_dut_tests_original()`: 原始批处理 (完整保留)
- `_build_bundle()`: WorkerResult → corpus-compatible dict
- `_evaluate_and_enqueue()`: 单种子评分 + 入队 (warmup 和主循环共用)

**worker.py** (新建):
- `worker_entry(task: WorkerTask) → WorkerResult`: ProcessPoolExecutor 入口
- `worker_generate()`: 生成单种子, 直调 `process_file()` (避免嵌套线程池)
- `worker_mutate()`: 变异某种子, 正确定位父 .S 文件
- `worker_execute()`: subprocess.run emu, per-seed observe 隔离
- `_setup_worker_singletons()`: spawn 模式兼容 (初始化 generator 单例)

### 8. fuzzer/model/ — 数据模型

**ExecuteResult** (result.py): 19 字段, 仅 6 个活跃使用 (其余为历史遗留):
```
case_id, status, csr_transitions, diff_families, syncable_count, potential_bug_count
```

**MutationRequest / MutationResult** (request.py): 未使用, 死代码。

### 9. fuzzer/tests/ — 测试

`test_feedback_loop.py` — 34 个集成测试, 10 个测试类:

| 测试类 | 数量 | 覆盖 |
|--------|------|------|
| TestScheduler | 7 | push/pop 优先级, 去重, saturation boost, pop_best, dump/restore |
| TestFeedbackSignals | 3 | 新覆盖信号, diff 增强, 零覆盖 |
| TestDecisionPolicy | 3 | diff→bug_proximity, executed→stable, no_coverage→keep |
| TestRunCorpus | 6 | record+dedup, dump/load, preview_coverage_delta, snapshot, delta_from_snapshot, rarities |
| TestSyncDecisionEngine | 4 | csr_write, fp_rounding, unknown, summary |
| TestObservation | 3 | empty inputs, DIFF_FAMILIES 7 族 |
| TestStatusEnums | 2 | CaseStatus, FailureKind |
| TestFitnessCalculator | 4 | evaluate, lineage_parent, dominant_category, empty inputs |
| TestSnapshotDelta | 2 | all_new, all_seen |

### 10. 持久化

**campaign_state.json** (`dump_campaign_state()`):
```json
{
  "coverage_points": ["privilege|csrrs", ...],
  "transition_keys_full": [...],        // 全量, 消除有损恢复
  "transition_frequency_sample": {...}, // 频率 top 1000 (调试用)
  "diff_family_counts": {...},
  "seed_fitness": {...},                // 运行时由 FitnessCalculator 填充
  "signatures": [...],
  "last_seed_id": N
}
```

**queue_state.json** (`scheduler.dump_queue()`):
```json
{
  "bug_proximity": [{"seed_id": "...", "score": 0.95, "lineage_parent": "...", "action": "generate"}],
  "stable_ancestor": [...],
  "exploration": [...]
}
```

**corpus_state.json** (`dump_state()`): 精简版, entries 列表 + 计数, 向后兼容。

---

## 反馈信号链路 (完整)

```
DUT 执行 (worker pool, M 个并行)
  └─ observation JSONL (difftest.observe.{seed_id}.jsonl, per-seed 隔离)
       ├─ parse_observation() → transitions + diff_families
       │
       ├─ [snapshot 隔离] corpus.preview_delta_from_snapshot(snapshot, transitions)
       │    └─ make_coverage_key() → {category}|{mnemonic} (粗粒度)
       │         └─ by_category: {cat: {new, total}}
       │
       ├─ corpus.preview_diff_delta(diff_families)
       │    └─ diff_novelty = new_families / total_families
       │
       ├─ SyncDecisionEngine.classify(diff_events)
       │    └─ syncable_count / potential_bug_count
       │
       ├─ FeedbackSignalExtractor.extract()
       │    └─ exploration_value = Σ(weight × rarity × new/total)
       │         └─ rarity 来自 corpus.get_category_rarities() (已激活)
       │
       ├─ FitnessCalculator.evaluate()
       │    ├─ category_affinity → GoalDirectedScheduler.tag_seed()
       │    ├─ lineage_depth → 追踪血统
       │    └─ corpus.update_seed_fitness()
       │
       ├─ FeedbackDecisionPolicy.decide()
       │    ├─ promote_mutation → push 原种子 + push 变异种子 (action="mutate")
       │    ├─ keep_in_corpus  → push (exploration)
       │    └─ archive_only → 不入队
       │
       └─ persist: campaign_state.json + queue_state.json
```

---

## 运行

```bash
# 从仓库根目录运行 (所有导入使用 fuzzer. 前缀)
PYTHONPATH=. python fuzzer/run_dut.py --config configs/rocket_feedback.yaml
```

## 测试

```bash
PYTHONPATH=. python -m pytest fuzzer/tests/test_feedback_loop.py -v
```
