# CLAUDE.md — DiveFuzz + RVFUZZ 反馈回路

## Architecture docs
- `docs/divefuzz-architecture-exploration.md` — 完整架构 (原始 + RVFUZZ 植入)
- `docs/rvfuzz-feedback-implantation.md` — 植入点映射 + 文件变更清单

## Dual-path execution
- 默认走 `_run_dut_tests_with_feedback()` (RVFUZZ P0-P8 闭环)
- 不传 feedback dict 时回退 `_run_dut_tests_original()` (原始批处理)

## Key directories
- `fuzzer/core/` — RVFUZZ 反馈回路 (observation, sync, scheduler, feedback_loop, corpus, fitness, status)
- `fuzzer/config/` — 配置解析 (dut_config, divefuzz_config, logger_config)
- `fuzzer/executor/` — DUT 测试执行 (dut_executor, divefuzz_adapter)
- `fuzzer/generator/` — 原装未修改 (XOR 去重, HybridEncoder, BugFilter, 模板)
- `fuzzer/tests/test_feedback_loop.py` — 22 个集成测试
- `configs/rocket_feedback.yaml` — 反馈回路配置示例

## Run
```bash
cd fuzzer && python run_dut.py --config ../configs/rocket_feedback.yaml
```

## Test
```bash
# Run from repo root — PYTHONPATH must include repo root for `from fuzzer.core...` imports
PYTHONPATH=. python -m pytest fuzzer/tests/test_feedback_loop.py -v
```

## Environment
- 环境配置与依赖安装详见 [README.md](README.md)
- 需要 SPIKE_HOME / riscv64-unknown-elf-* toolchain / pip install -r requirements.txt

## Key invariants
- core/ 组件通过 duck-typed dict/object 兼容层与 generator 交互
- batch_size 控制反馈回路迭代次数 (非种子批量大小)
- PYTHONPATH 须指向仓库根目录 (非 fuzzer/)，代码使用 `from fuzzer.core...` 导入
