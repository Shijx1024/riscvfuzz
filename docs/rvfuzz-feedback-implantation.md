# RVFUZZ Feedback Loop Implantation Report

> 2026-05-06 — 在 DiveFuzz 控制流中植入 RVFUZZ 反馈回路

## 目标

以 DiveFuzz 项目为基础蓝本，保留其生成器完整不变（Spike XOR 去重、HybridEncoder、BugFilter、模板系统），在其控制流中按序植入 RVFUZZ 的反馈回路组件，实现闭环迭代 fuzzing。

## 架构变更

```
Before (DiveFuzz 原始):                After (植入后):

run_dut.py                            run_dut.py
  └─ for seed_config:                   ├─ [P0] Init feedback components
       ├─ generate N seeds              └─ while index < batch_size:
       ├─ execute N seeds                    ├─ [P1] scheduler.pop_next()
       └─ report                             ├─ [P2] run_divefuzz_single()
                                                  │    └─ generate 1 seed (DiveFuzz 原装)
                                                  ├─ [P3] execute + observe
                                                  │    ├─ subprocess.run(emu)
                                                  │    ├─ extract_csr_transitions()
                                                  │    ├─ classify_diff_family()
                                                  │    └─ SyncDecisionEngine
                                                  ├─ [P4] FeedbackSignalExtractor
                                                  ├─ [P5] FeedbackDecisionPolicy
                                                  ├─ [P7] scheduler.update_saturation()
                                                  ├─ [P6] promote_mutation → mutate
                                                  └─ [P8] corpus.dump_state()
```

## 植入点映射

| 植入点 | 文件 | 位置 | 组件 |
|--------|------|------|------|
| P0 初始化 | `run_dut.py` | `run_dut_tests()` 调用前 | RunCorpus, Scheduler, SignalExtractor, DecisionPolicy |
| P1 调度 | `dut_executor.py` | 替代 `for seed_config` 外层循环 | `scheduler.pop_next()` 驱动生成参数 |
| P2 单种子生成 | `divefuzz_adapter.py` | 新增 `run_divefuzz_single()` | 调用 `generate_instructions_parallel(seed_times=1)` |
| P3 执行后观测 | `dut_executor.py` | `subprocess.run` 返回后 | `extract_csr_transitions`, `classify_diff_family`, `SyncDecisionEngine` |
| P4 信号提取 | `dut_executor.py` | 观测后 | `FeedbackSignalExtractor.extract()` |
| P5 决策 | `dut_executor.py` | 信号提取后 | `FeedbackDecisionPolicy.decide()` |
| P6 变异 | `dut_executor.py` | `promote_mutation` 分支 | `scheduler.push(mutated_seed)` |
| P7 调度更新 | `dut_executor.py` | 决策后 | `scheduler.update_saturation()`, `scheduler.push()` |
| P8 持久化 | `run_dut.py` | 循环结束后 | `corpus.dump_state()` |

## 文件变更

### 新建 (15 文件)

```
fuzzer/core/
  __init__.py               # 空
  status.py                 # CaseStatus, FailureKind, ArtifactKind, RunStatus 枚举
  observation.py            # extract_csr_transitions, classify_diff_family, CSR_CATEGORIES
  sync.py                   # SyncDecisionEngine (13 条同步/漏洞判定规则)
  scheduler.py              # GoalDirectedScheduler + MultiQueueScheduler
  feedback_loop.py          # FeedbackSignalExtractor + FeedbackDecisionPolicy
  corpus.py                 # RunCorpus (去重, 稀有度, 持久化)
  fitness.py                # SeedFitness, FitnessCalculator, MUTATION_STRATEGIES

fuzzer/model/
  __init__.py               # 空
  request.py                # MutationRequest dataclass
  result.py                 # ExecuteResult, MutationResult dataclasses

fuzzer/utils/
  serde.py                  # dump_json 工具

fuzzer/tests/
  __init__.py               # 空
  test_feedback_loop.py     # 22 个集成测试

docs/
  divefuzz-architecture-exploration.md  # 本报告
  rvfuzz-feedback-implantation.md       # DiveFuzz 架构探索报告
```

### 修改 (5 文件)

```
fuzzer/run_dut.py                     # P0: init feedback + P8: dump corpus
fuzzer/config/dut_config.py           # DUTTarget (+observe_path, +observe_level), Config (+batch_size, +corpus fields)
fuzzer/executor/dut_executor.py       # P1-P7: 反馈循环主逻辑, _run_dut_tests_with_feedback()
fuzzer/executor/divefuzz_adapter.py   # P2: run_divefuzz_single() 单种子生成
fuzzer/utils/results_reporter.py      # TestResult (+observation_path, +duration_s)
```

## 未修改的 DiveFuzz 组件

以下组件保持原装不变：

- `generator/` — 指令生成和变异引擎 (Spike XOR, HybridEncoder, BugFilter, Template)
- `ref/riscv-isa-sim-adapter/` — Spike + pybind11 checkpoint engine
- `dut/` — RTL 仿真器
- `config/divefuzz_config.py` — DiveFuzzArgConfig
- `config/config_manager.py` — 扩展配置管理器
- 原始 `run_single_seed()`, `_run_dut_tests_original()` — 向后兼容（不传 feedback dict 时行为不变）

## 反馈信号链路

```
DUT 执行
  └─ observation JSONL
       ├─ extract_csr_transitions()
       │    └─ 6 CSR 类别: privilege, float, control, memory, counter, misc
       │         └─ RunCorpus 去重 + rarity 计算
       │              └─ exploration_value = Σ(weight × rarity × new/total)
       │
       ├─ classify_diff_family()
       │    └─ 7 diff 族: fp_rounding, fp_nan, csr_write, trap_difference,
       │                  pc_divergence, memory_ordering, unknown
       │         └─ diff_novelty_score → exploration_value 加成
       │
       └─ SyncDecisionEngine.classify()
            └─ syncable / potential_bug 判定
                 └─ FeedbackDecisionPolicy
                      ├─ DIFF/REF/BADTRAP/TIMEOUT → promote_mutation (bug_proximity)
                      ├─ EXECUTED + 新覆盖         → promote_mutation (stable_ancestor)
                      └─ EXECUTED 无新覆盖         → keep_in_corpus (exploration)
```

## 配置文件扩展

YAML 配置中新增字段（均有默认值，向后兼容）：

```yaml
dut_target:
  - name: rocket
    observe_path: "difftest.observe.jsonl"   # NEW
    observe_level: "all"                      # NEW

campaign_id: "rocket-fb"        # NEW
batch_size: 100                 # NEW (循环迭代次数)
corpus_max_retained: 1024       # NEW
corpus_dir: "outputs"           # NEW (跨 run 持久化)
```

## 测试

```
fuzzer/tests/test_feedback_loop.py — 22 tests in 7 classes:

TestScheduler           (4) — pop 优先级, 去重, saturation boost, exhausted
TestFeedbackSignals     (3) — 新覆盖信号, diff 增强, 零覆盖
TestDecisionPolicy      (3) — diff_failed→bug_proximity, executed→stable, no_coverage→keep
TestRunCorpus           (3) — record+dedup, dump/load, preview_coverage_delta
TestSyncDecisionEngine  (4) — csr_write syncable, fp_rounding syncable, unknown bug, summary
TestObservation         (3) — empty inputs, DIFF_FAMILIES 7 族
TestStatusEnums         (2) — CaseStatus, FailureKind 枚举值
```

## 兼容性

- `run_dut_tests(config, config_filename)` — 不传 feedback 参数时使用原始 DiveFuzz 行为
- `run_dut_tests(config, config_filename, feedback={...})` — 启用反馈回路
- 所有原始 YAML 配置文件无需修改即可使用
