# DiveFuzz Architecture Exploration Report

> 2026-05-06 — 为 RVFUZZ 反馈回路植入进行的全面架构分析
>
> **更新 2026-05-06** — 补充 RVFUZZ 反馈回路植入后的架构变更、fuzzer/core/ 模块详解、双路径控制流

## 项目概览

DiveFuzz 是中科院信息工程研究所开发的 RISC-V CPU 差分模糊测试框架，支持 XiangShan、NutShell、Rocket、CVA6、BOOM 等多个 CPU 目标。

## 目录结构

```
learn/DiveFuzz/
  fuzzer/                  # 核心 fuzzer 代码
    run_dut.py             # 主入口 (YAML 驱动)
    config/                # 配置解析 (dut_config, divefuzz_config, logger_config)
    executor/              # DUT 测试执行 (dut_executor, divefuzz_adapter)
    utils/                 # elf_to_img, results_reporter, serde
    generator/             # 指令生成与变异引擎 (核心, 原装未修改)
      main.py              # 独立生成器入口
      config/              # CLI 解析器, config_manager
      core/
        generator/         # generate_instrs.py, register_history.py, 并行分派
        mutator/           # mutate_instructions.py, modify_instr.py, data_collector.py
      instr_generator/     # 指令集定义, 格式模板, 变量范围
      reg_analyzer/        # SpikeSession, InstructionValidator, XORCache, HybridEncoder
      asm_template_manager/ # 汇编模板 (header/footer per CPU)
      bug_filter/          # 精度过滤器框架 (pre-execute + post-execute, 按架构注册)
      utils/
    core/                  # [RVFUZZ 新增] 反馈回路组件
      status.py            # CaseStatus, FailureKind, ArtifactKind, RunStatus 枚举
      observation.py       # CSR 转移提取 + Diff 族分类
      sync.py              # SyncDecisionEngine (13 条同步/漏洞判定规则)
      scheduler.py         # MultiQueueScheduler + GoalDirectedScheduler
      feedback_loop.py     # FeedbackSignalExtractor + FeedbackDecisionPolicy
      corpus.py            # RunCorpus (去重, 稀有度, 持久化)
      fitness.py           # SeedFitness, FitnessCalculator, MUTATION_STRATEGIES
    model/                 # [RVFUZZ 新增] 数据模型
      request.py           # MutationRequest dataclass
      result.py            # ExecuteResult, MutationResult dataclasses
    tests/                 # [RVFUZZ 新增] 测试
      test_feedback_loop.py # 22 个集成测试
  dut/                     # RTL 仿真器 (子模块)
    rocket-chip/           # Rocket Chip (Chisel RISC-V SoC)
    NutShell/              # NutShell CPU
    XiangShan/             # 香山 CPU (子模块, 未本地克隆)
  ref/                     # 参考模拟器 (子模块)
    riscv-isa-sim-adapter/ # 修改的 Spike + pybind11 checkpoint engine
    riscv-isa-sim/         # 原版 Spike (非直接使用)
  configs/                 # [RVFUZZ 新增] 反馈回路配置
    rocket_feedback.yaml   # Rocket + 反馈回路集成测试配置
  docs/
    divefuzz-architecture-exploration.md  # 本报告 (架构探索)
    rvfuzz-feedback-implantation.md       # RVFUZZ 植入报告 (文件变更、植入点映射)
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
  └─ run_dut_tests(config, config_filename, feedback={...})
       ├─ if feedback is not None:
       │    _run_dut_tests_with_feedback()  ← 默认路径 (RVFUZZ 回路)
       └─ else:
            _run_dut_tests_original()       ← 向后兼容 (原始批处理)
```

### 路径 A：RVFUZZ 反馈回路 (默认, `_run_dut_tests_with_feedback`)

```
run_dut.py
  └─ while index < batch_size:
       ├─ [P1] scheduler.pop_next()
       │        └─ 三队列优先级: bug_proximity > exploration > stable_ancestor
       │        └─ GoalDirectedScheduler: 低饱和度类别 boost (< 0.3)
       ├─ [P2] run_divefuzz_single()
       │        └─ generate_instructions_parallel(seed_times=1, max_workers=1)
       │             └─ 生成 1 个种子 (DiveFuzz 原装生成器)
       ├─ [P3] run_single_seed_with_observation()
       │        ├─ subprocess.run(emu_cmd)
       │        ├─ extract_csr_transitions(observe_path)
       │        │    └─ 解析 JSONL coverage 事件 → (csr, prev, curr, instr, category)
       │        ├─ classify_diff_family(observe_path)
       │        │    └─ 解析 JSONL error/mismatch 事件 → 7 族标签
       │        └─ SyncDecisionEngine.classify(diff_events)
       │             └─ syncable / potential_bug 判定
       ├─ [P4] FeedbackSignalExtractor.extract()
       │        └─ 计算 exploration_value (加权稀有度 × 新颖性)
       ├─ [P5] FeedbackDecisionPolicy.decide()
       │        ├─ DIFF/REF/BADTRAP/TIMEOUT/COVERAGE_FAILED → promote_mutation (bug_proximity)
       │        ├─ EXECUTED + 新覆盖                          → promote_mutation (stable_ancestor)
       │        ├─ EXECUTED + 无新覆盖                        → keep_in_corpus (exploration)
       │        └─ GENERATED                                  → archive_only
       ├─ [P6] promote_mutation 时:
       │        scheduler.push(mut-{seed}, queue=decision.queue)
       ├─ [P7] scheduler.push(gen-{next_index}, queue=exploration)
       │        scheduler.update_saturation(category_deltas, rarities)
       └─ [P8] corpus.dump_state() — 循环结束后持久化
```

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

**关键特征:** 原始 DiveFuzz 没有传统的生成→执行→反馈循环。它是一次性的两阶段管道：生成 N 个种子 → 批量执行 → 报告结果。RVFUZZ 植入后，默认路径变为逐种子迭代的闭环 fuzzing。

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

### 4. Bug Filter (`bug_filter/`)

```python
# 两级过滤 + 按架构注册
FilterRegistry:
  - pre_execute:  基于 opcode + 寄存器值 + CSR 状态 + 特权级预判
  - post_execute: 基于 Spike 执行后的 CSR 状态差异
  - 按架构注册: xs (XiangShan), nts (NutShell), boom (BOOM), cva6 (CVA6), rkt (Rocket)
  - FilterContext 懒加载: XPR, FPR, CSR, PC, privilege, virtualization, reservation, trap, vector
```

以 XiangShan 为例，包含类别: V-5 (vstart_nonzero), C-1 (cycle_counter_read), W-15 (frm_reserved), M-1 (misaligned_access), P-1 (wfi_timeout), T-1 (trap_tval), W-2 (tvec_base_alignment), W-3 (mstatus_fs_vs_warl), C-4 (minstret_trap_boundary) 等。

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

#### 6.1 status.py — 状态枚举

```python
CaseStatus:  GENERATED | GENERATION_FAILED | INVALID_PROGRAM | EXECUTED |
            DIFF_FAILED | REFERENCE_FAILED | BADTRAP | TIMEOUT |
            INFRA_ERROR | COVERAGE_FAILED | ARCHIVED_NO_NOVELTY | SYNCABLE_NO_BUG

FailureKind: GENERATION_ERROR | INVALID_PROGRAM | BAD_TRAP | INFRA_ERROR |
             REFERENCE_ERROR | DIFF_MISMATCH | TIMEOUT | COVERAGE_COLLECTION_FAILED

ArtifactKind: ASM | BIN | IMG | ELF_ALIAS | RAW_ELF | DUMP | SYMBOL |
              CMD_HISTORY | COVERAGE_RAW

RunStatus:    RUNNING | COMPLETED | ABORTED
```

#### 6.2 observation.py — CSR 转移 + Diff 族

**CSR 类别 (5+1):**

| 类别 | CSR 寄存器 | 权重 |
|------|-----------|------|
| privilege | mstatus, scause, mcause, medeleg, mideleg, sstatus | 1.0 |
| float | frm, fflags, fcsr | 0.8 |
| control | mepc, sepc, mtvec, stvec, mtval, stval, mscratch, sscratch | 0.9 |
| memory | satp, pmpcfg0-3, pmpaddr0-15 | 1.2 |
| counter | cycle, instret, mcycle, minstret, mcounteren, scounteren, mhpmevent3-31 | 0.5 |
| misc | (所有未在以上 5 类中的 CSR) | 0.3 |

`extract_csr_transitions(observation_path)` 从 DiffTest JSONL 解析 coverage 事件：
- 格式: `csr:{name}:{prev}->{curr}:{instr}`
- 过滤: 去除 trivial CSR-write（仅目标 CSR 变化且指令为 csrw/csrwi/csrs/csrc）
- 返回每条的 `{csr, prev_value, curr_value, instr, category}`

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

`classify_diff_family(observation_path)` 仅处理 severity=error/fatal 或 event=mismatch 的事件。

#### 6.3 sync.py — 同步判定引擎

`SyncDecisionEngine` 对 diff 事件分类为 `syncable` 或 `potential_bug`：

**Syncable (可同步，非 Bug):**
- `csr_write` on mstatus/sstatus → "FS field implementation difference"
- `csr_write` on fflags/fcsr → "FP CSR implementation difference"
- `csr_write` on frm → "Rounding mode implementation difference"
- `fp_rounding` → "FP rounding +/-1ulp"
- `fp_nan` → "Both sides NaN"
- `trap_difference` with same mcause → "Same exception type, timing difference"

**Potential Bug (潜在漏洞):**
- `csr_write` on sepc/mepc → "LSB may be non-zero"
- `csr_write` on mhartid → "should be read-only zero"
- `csr_write` on other CSR → "CSR write mismatch"
- `trap_difference` with different mcause → "Different exception types"
- 其余所有族 → "Unclassified mismatch"

#### 6.4 scheduler.py — 目标导向调度器

**MultiQueueScheduler** — 三队列优先级:
```
bug_proximity (最高)  → 接近 Bug 的种子 (DIFF/REF/BADTRAP/TIMEOUT)
exploration           → 探索性种子 (默认)
stable_ancestor       → 产生新覆盖的已执行种子
```

去重: `_seen_seeds` 集合防止重复入队。

**GoalDirectedScheduler** — 基于类别饱和度的优先级 Boost:
- 每类别计算饱和度: `saturation = 1.0 - rarity × (0.5 + 0.5 × novelty_rate)`
- 当某类别 saturation < 0.3 时，扫描所有队列寻找标记为该类别的种子并优先弹出
- `tag_seed(seed, category)` 标记种子最常触发的 CSR 类别
- `update_saturation(category_deltas, transition_rarities)` 更新饱和度

**ScheduledSeed**: `{seed, queue, lineage_parent}`

#### 6.5 feedback_loop.py — 信号提取 + 决策

**FeedbackSignalExtractor**:
- 按类别加权计算 `exploration_value = Σ(weight × rarity × new/total) / Σ(weight)`
- 有 diff 时 `exploration_value = max(exploration_value, 0.5 + 0.5 × diff_novelty_score)`
- 无类别增量时用简单覆盖率比例
- 输出 `FeedbackSignals{status, coverage_new_points, coverage_total_points, duration_s, exploration_value, diff_novelty_score, syncable_count}`

**FeedbackDecisionPolicy**:
```
DIFF_FAILED / REFERENCE_FAILED / BADTRAP / TIMEOUT / COVERAGE_FAILED
  → promote_mutation (bug_proximity, score=1.0)

EXECUTED + coverage_new_points > 0
  → promote_mutation (stable_ancestor, score=max(0.1, exploration_value))

EXECUTED + 无新覆盖
  → keep_in_corpus (exploration, score=0.2)

GENERATED
  → archive_only (exploration, score=0.1)

其他
  → discard (exploration, score=0.0)
```

#### 6.6 corpus.py — 运行语料库

`RunCorpus` 管理模糊测试运行中的种子多样性、去重和持久化：

- **去重**: `_seen_signatures` (SHA1 签名), `_seen_coverage_points`, `_seen_transitions`
- **记住**: `_retained_seed_order` (FIFO, max_retained=1024)
- **稀有度**: `_transition_frequency` → `get_transition_rarity(key) = 1/(1+log2(1+freq))`
- **持久化**: `dump_state()` (精简), `dump_campaign_state()` (全面，含 seed fitness)
- **恢复**: `bootstrap_from_campaign_state()` 从上次运行恢复状态
- **兼容性**: `_get()`/`_set()` helper 可同时处理对象属性和 dict (跨 RVFUZZ/DiveFuzz)

`CorpusEntry`: `{case_id, seed, status, failure_kind, signature, decision, queue, lineage_parent, manifest_path, coverage_*}`

#### 6.7 fitness.py — 种子适应度

**SeedFitness**: `{seed, category_affinity, novelty_score, diff_diversity, exploration_score, lineage_depth}`

**MUTATION_STRATEGIES** — 基于类别的块级变异策略:

| 策略 | 触发类别 | 动作 |
|------|---------|------|
| boost_memory | memory | 追加 LoadStoreBlock, AmoBlock (+30% ratio) |
| boost_control | control | 追加 SystemOperationBlock, branch retarget |
| boost_privilege | privilege | 追加 CsrBlock, 偏向 privilege CSRs |
| boost_float | float | 追加 FloatArithmeticBlock |
| boost_counter | counter | 追加 CsrBlock, 偏向 counter CSRs |
| explore_crossover | (通用) | merge=True |

**FitnessCalculator**:
- `evaluate()`: 计算类别亲和力 (new/total per category)、新颖性、diff 多样性
- `update_lineage()`: 子代继承父代适应度 (EMA, α=0.3)，实现血统追踪

### 7. fuzzer/model/ — 数据模型

**MutationRequest** (request.py):
```
case_id, seed, coverage_new/total_points, coverage_delta_ratio,
coverage_points, observation_counts, first_failure_event,
seed_fitness, target_category, category_saturation
```

**ExecuteResult** (result.py):
```
case_id, status, exit_code, command, reference_name, duration_s,
failure_kind, message, observation_path, observation_counts,
observation_coverage_points, first_failure_event, observation_total_events,
observation_max_cycle, observation_max_instr, observation_unique_pc_pages,
csr_transitions, diff_families, sync_decisions, syncable_count, potential_bug_count
```

**MutationResult** (result.py):
```
case_id, status, next_seed, message
```

### 8. fuzzer/tests/ — 测试

`test_feedback_loop.py` — 22 个集成测试，7 个测试类:

| 测试类 | 数量 | 覆盖 |
|--------|------|------|
| TestScheduler | 4 | pop 优先级, 去重, saturation boost, exhausted |
| TestFeedbackSignals | 3 | 新覆盖信号, diff 增强, 零覆盖 |
| TestDecisionPolicy | 3 | diff→bug_proximity, executed→stable, no_coverage→keep |
| TestRunCorpus | 3 | record+dedup, dump/load, preview_coverage_delta |
| TestSyncDecisionEngine | 4 | csr_write syncable, fp_rounding syncable, unknown bug, summary |
| TestObservation | 3 | empty inputs, DIFF_FAMILIES 7 族 |
| TestStatusEnums | 2 | CaseStatus, FailureKind 枚举值 |

### 9. configs/ — 反馈回路配置

`rocket_feedback.yaml` — 完整示例:

```yaml
dut_target:
  - name: rocket
    emu_path: /path/to/rocket-chip
    cmd: "SPIKE_HOME=... ./build/emu -i $1"
    threads: 1
    observe_path: "difftest.observe.jsonl"   # RVFUZZ 新增
    observe_level: "all"                      # RVFUZZ 新增

seeds:
  - name: rocket-fb-test
    input: divefuzz
    divefuzz:
      mode: generate
      dive_enable: true         # XOR 去重
      seeds_num: 1              # 每次迭代 1 个种子
      ins_num: 200
      template_type: rocket
      architecture: rkt

campaign_id: rocket-feedback-test   # RVFUZZ 新增
batch_size: 10                      # RVFUZZ 新增 (循环迭代次数)
corpus_max_retained: 100            # RVFUZZ 新增
corpus_dir: /tmp/divefuzz-rocket-corpus  # RVFUZZ 新增 (跨 run 持久化)
```

---

## 反馈信号链路 (完整)

```
DUT 执行
  └─ observation JSONL (difftest.observe.jsonl)
       ├─ extract_csr_transitions()
       │    └─ 6 CSR 类别: privilege, float, control, memory, counter, misc
       │         └─ RunCorpus.preview_transition_delta()
       │              └─ 按类别: new/total + transition_rarity
       │                   └─ exploration_value = Σ(weight × rarity × new/total)
       │
       ├─ classify_diff_family()
       │    └─ 7 diff 族: fp_rounding, fp_nan, csr_write, trap_difference,
       │                  pc_divergence, memory_ordering, unknown
       │         └─ diff_novelty_score → exploration_value 加成
       │
       └─ SyncDecisionEngine.classify()
            └─ syncable / potential_bug 判定 (13 条规则)
                 └─ FeedbackDecisionPolicy.decide()
                      ├─ DIFF/REF/BADTRAP/TIMEOUT → promote_mutation (bug_proximity)
                      ├─ EXECUTED + 新覆盖         → promote_mutation (stable_ancestor)
                      ├─ EXECUTED + 无新覆盖       → keep_in_corpus (exploration)
                      └─ 签名重复                  → archive_only (dedup)
```

---

## 依赖

| 依赖 | 用途 |
|------|------|
| Spike (riscv-isa-sim-adapter) | 运行时值 XOR 去重 + 指令验证 |
| riscv64-unknown-elf-* | 汇编/链接/objcopy |
| pybind11 ~=3.0.1 | Python-C++ 桥接 |
| PyYAML ~=5.4.1 | YAML 配置解析 |
| numpy ~=2.2.4 | 概率分布, Z-score |

---

## 与 RVFUZZ 的差异

### 原始 DiveFuzz vs RVFUZZ

| 特性 | DiveFuzz (原始) | RVFUZZ (原) |
|------|----------|-------------|
| 指令生成 | 平坦序列, 随机扩展→指令 | CSP 求解 + Block 结构 |
| 多样性保证 | Spike 运行时值 XOR (深) | 寄存器编号 XOR (浅) |
| 反馈回路 | 无 (一次性管道) | 完整闭环 (Scheduler→Signal→Decision→Mutation) |
| 变异 | 指令级 (频率统计 + Z-score) | Block 级 (追加 block 类型) |
| 覆盖率 | 无 | CSR 转移 (5+1 类) + Diff 族 (7 类) |
| 程序结构 | 平坦指令 + 模板 header/footer | Block 语义容器 |
| DUT 支持 | 多 CPU (XS/NTS/RKT/CVA6/BOOM) | Rocket only |

### 当前 DiveFuzz (植入后) vs RVFUZZ

| 特性 | DiveFuzz (当前) | RVFUZZ (原) |
|------|----------|-------------|
| 指令生成 | 平坦序列 + XOR 去重 (保留) | CSP 求解 + Block 结构 |
| 多样性保证 | Spike 运行时值 XOR (深, 保留) | 寄存器编号 XOR (浅) |
| 反馈回路 | **有** (RVFUZZ 植入: Scheduler→Signal→Decision→Mutation) | 完整闭环 |
| 变异 | 指令级 (Z-score, 保留) + **Block 策略指导** (fitness.py) | Block 级 |
| 覆盖率 | **有** (CSR 转移 6 类 + Diff 族 7 类) | CSR 转移 6 类 + Diff 族 7 类 |
| 程序结构 | 平坦指令 + 模板 | Block 语义容器 |
| DUT 支持 | 多 CPU + **Rocket 反馈回路** | Rocket only |
| 调度器 | GoalDirectedScheduler (三队列 + 饱和度 Boost) | GoalDirectedScheduler |
| 持久化 | RunCorpus.dump_state / dump_campaign_state | 类似 |
| 测试 | 22 个集成测试 | 同 |

**关键差异保留:** DiveFuzz 的生成器（Spike XOR 去重、HybridEncoder、BugFilter、多 CPU 模板系统）全部保持不变。RVFUZZ 植入仅在外层控制流和反馈组件层面。DiveFuzz 的指令级变异仍为主变异机制，fitness.py 中的 Block 策略目前作为配置指导。

---

## 兼容性

- `run_dut_tests(config, config_filename)` — 不传 feedback 参数 → 原始批处理行为
- `run_dut_tests(config, config_filename, feedback={...})` — 启用反馈回路
- 所有原始 YAML 配置文件无需修改即可使用 (新增字段均有默认值)
- 原始 `_run_dut_tests_original()` 完整保留
- 反馈组件 (core/) 独立于生成器，不修改 DiveFuzz 原装代码
