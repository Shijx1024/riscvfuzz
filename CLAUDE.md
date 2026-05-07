# CLAUDE.md — DiveFuzz + RVFUZZ 反馈回路

## Architecture
- **Manager-Worker 批量模式**: 主进程持有 corpus/scheduler, ProcessPoolExecutor worker 池 (M = dut_config.threads) 并行 gen→exec→observe
- `docs/divefuzz-architecture-exploration.md` — 完整架构
- `docs/superpowers/specs/2026-05-07-multiprocess-feedback-loop-design.md` — 多进程设计 spec
- `docs/superpowers/plans/2026-05-07-multiprocess-feedback-loop-plan.md` — 实现计划

## Execution paths
- `_run_dut_tests_with_feedback()` — Manager-Worker 批量闭环 (默认)
- `_run_dut_tests_original()` — 原始批处理 (无 feedback dict 时回退)

## Key directories
- `fuzzer/core/` — 反馈回路 (seed_ref, scheduler, corpus, feedback_loop, fitness, observation, sync, status)
- `fuzzer/executor/` — DUT 执行 (dut_executor: 调度循环, worker: 无状态 worker 函数, divefuzz_adapter)
- `fuzzer/generator/` — 原装未修改
- `fuzzer/tests/test_feedback_loop.py` — 34 个集成测试

## Run
```bash
# Must run from repo root with PYTHONPATH=. (all imports use fuzzer. prefix)
PYTHONPATH=. python fuzzer/run_dut.py --config configs/rocket_feedback.yaml
```

## Test
```bash
PYTHONPATH=. python -m pytest fuzzer/tests/test_feedback_loop.py -v
```

## Environment
- 环境配置与依赖安装详见 [README.md](README.md)
- 需要 SPIKE_HOME / riscv64-unknown-elf-* toolchain / pip install -r requirements.txt

## Key invariants
- **Import rule**: 所有跨目录导入必须用 `from fuzzer.xxx` 前缀, 混用 `from config.x` 和 `from fuzzer.config.x` 会导致 isinstance 失败 (Python 当作不同模块)
- batch_size 控制反馈回路 batch 轮数; dut_config.threads 控制 worker 池大小 M
- **Paths**: 传给 worker 的路径必须 `.resolve()` 转绝对路径 (worker 的 CWD 与主进程不同)
- **Seed path**: `{corpus_dir}/seeds/{seed_id}/img_file/seed_0.img`
- **Observe files**: worker 使用 `difftest.observe.{seed_id}.jsonl` 隔离, 解析后自动删除
- **Mutation**: DiveFuzz 原生 mutator 在指令分布均匀时产生空序列, 需足够复杂程序才能成功变异
