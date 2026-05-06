# DiveFuzz Architecture Exploration Report

> 2026-05-06 — 为 RVFUZZ 反馈回路植入进行的全面架构分析

## 项目概览

DiveFuzz 是中科院信息工程研究所开发的 RISC-V CPU 差分模糊测试框架，支持 XiangShan、NutShell、Rocket、CVA6、BOOM 等多个 CPU 目标。

## 目录结构

```
learn/DiveFuzz/
  fuzzer/                  # 核心 fuzzer 代码
    run_dut.py             # 主入口 (YAML 驱动)
    config/                # 配置解析 (dut_config, divefuzz_config, logger_config)
    executor/              # DUT 测试执行 (dut_executor, divefuzz_adapter)
    utils/                 # elf_to_img, results_reporter
    generator/             # 指令生成与变异引擎 (核心)
      main.py              # 独立生成器入口
      config/              # CLI 解析器, config_manager
      core/
        generator/         # generate_instrs.py, 并行分派
        mutator/           # mutate_instructions.py, 指令级变异
      instr_generator/     # 指令集定义, 格式模板, 变量范围
      reg_analyzer/        # SpikeSession, InstructionValidator, XORCache, HybridEncoder
      asm_template_manager/ # 汇编模板 (header/footer per CPU)
      bug_filter/          # 精度过滤器框架
      utils/
  dut/                     # RTL 仿真器 (子模块)
    rocket-chip/           # Rocket Chip (Chisel RISC-V SoC)
    NutShell/              # NutShell CPU
    XiangShan/             # 香山 CPU (子模块, 未本地克隆)
  ref/                     # 参考模拟器 (子模块)
    riscv-isa-sim-adapter/ # 修改的 Spike + pybind11 checkpoint engine
    riscv-isa-sim/         # 原版 Spike (非直接使用)
```

## 控制流

### 主入口 `run_dut.py`

```
main()
  ├─ Config.from_yaml(args.config)
  └─ run_dut_tests(config, config_filename)
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

**关键特征:** DiveFuzz 没有传统的生成→执行→反馈循环。它是一次性的两阶段管道：生成 N 个种子 → 批量执行 → 报告结果。

## 核心机制

### 1. 指令生成 (`generate_instrs.py`)

```
while instr_count < target:
  1. 按概率选择扩展 (RV64_I, RV64_M, RV64_F, RV64_D, RV64_C, RV_V)
  2. 随机选择该扩展内的指令 opcode
  3. 从 RegisterHistory 选择寄存器 (LRU 队列, capacity=6)
  4. gen_imm() 生成立即数 (10% 边界值)
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
- **StatefulXORCache**: 扩展为上下文感知（浮点舍入模式、向量状态、特权级）
- **关键**: 使用 Spike **运行时寄存器值**做 XOR，不是寄存器编号

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
# 两级过滤
FilterRegistry:
  - pre_execute:  基于 opcode + 寄存器值 + 特权级预判
  - post_execute: 基于 Spike 执行后的 CSR 状态
  - 按架构注册: XS, NTS, BOOM, CVA6, Rocket
```

### 5. Spike Integration (`riscv-isa-sim-adapter/`)

```
spike_engine (C++ pybind11):
  ├─ checkpoint.cpp   → 高效 checkpoint save/restore
  ├─ state_query.cpp  → 寄存器/CSR/内存/向量状态读取
  ├─ bindings.cpp     → pybind11 模块导出
  └─ Makefile         → 链接 libspike.a
```

## 依赖

| 依赖 | 用途 |
|------|------|
| Spike (riscv-isa-sim-adapter) | 运行时值 XOR 去重 + 指令验证 |
| riscv64-unknown-elf-* | 汇编/链接/objcopy |
| pybind11 ~=3.0.1 | Python-C++ 桥接 |
| PyYAML ~=5.4.1 | YAML 配置解析 |
| numpy ~=2.2.4 | 概率分布, Z-score |
| tqdm ~=4.67.1 | 进度条 |

## 与 RVFUZZ 的差异

| 特性 | DiveFuzz | RVFUZZ (原) |
|------|----------|-------------|
| 指令生成 | 平坦序列, 随机扩展→指令 | CSP 求解 + Block 结构 |
| 多样性保证 | Spike 运行时值 XOR | 寄存器编号 XOR (浅) |
| 反馈回路 | 无 (一次性管道) | 完整闭环 (Scheduler→Signal→Decision→Mutation) |
| 变异 | 指令级 (频率统计 + Z-score) | Block 级 (追加 block 类型) |
| 覆盖率 | 无 | CSR 转移 (6类) + Diff 族 (7类) |
| 程序结构 | 平坦指令 + 模板 header/footer | Block 语义容器 |
| DUT 支持 | 多 CPU (XS/NTS/RKT/CVA6/BOOM) | Rocket only |
