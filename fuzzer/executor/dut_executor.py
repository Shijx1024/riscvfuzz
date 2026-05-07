# Copyright (c) 2024-2025 Institute of Information Engineering, Chinese Academy of Sciences
# 
# DiveFuzz is licensed under Mulan PSL v2.
# You can use this software according to the terms and conditions of the Mulan PSL v2.
# You may obtain a copy of Mulan PSL v2 at:
#          http://license.coscl.org.cn/MulanPSL2
# 
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# 
# See the Mulan PSL v2 for more details.

import os
import subprocess
import logging
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Any
import glob
from fuzzer.config.logger_config import create_test_logger
from fuzzer.config.dut_config import Config, DUTTarget, DirSeedConfig, GeneratedSeedConfig, SeedConfigBase
from fuzzer.executor.divefuzz_adapter import setup_divefuzz, run_divefuzz, run_divefuzz_single, run_divefuzz_mutate
from fuzzer.utils.results_reporter import TestResult, ResultType, format_duration, generate_result_report, generate_summary_report
from fuzzer.core.seed_ref import SeedRef, WorkerTask, WorkerResult
from fuzzer.core.status import CaseStatus, FailureKind

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# RVFUZZ helper functions — seed ID allocation, bundle construction
# ---------------------------------------------------------------------------


def _build_bundle(seed_ref: SeedRef, result: WorkerResult,
                  execute_result: Any) -> dict[str, Any]:
    """Build a corpus-compatible bundle dict from typed worker data."""
    from fuzzer.core.observation import make_coverage_key
    points = {make_coverage_key(t) for t in result.transitions}
    return {
        "case_id": result.seed_id,
        "seed": seed_ref.seed_id,
        "lineage_parent": seed_ref.lineage_parent,
        "status": result.status,
        "coverage_result": {"points": points, "status": "collected"},
        "execute_result": execute_result,
        "feedback_decision": None,
    }


def _allocate_seed_id(corpus: Any) -> str:
    """Allocate next sequential seed_id."""
    next_id = getattr(corpus, '_next_seed_id', 0) + 1
    corpus._next_seed_id = next_id
    return f"{next_id:06d}"


def run_single_seed(seed_path: str, seed_name: str, dut_config: DUTTarget, seed_config_name: str, test_logger: logging.Logger) -> TestResult:
    """Run a single seed and return the result"""
    # Create path-safe seed name
    safe_seed_name = seed_name.replace(" ", "_").replace(os.sep, "_")
    # create logger for this seed
    with create_test_logger(
        test_name=safe_seed_name,
        config_filename=seed_config_name,
        enable_timestamp=False
    ) as (seed_logger, seed_log_path):
        try:
            command = dut_config.cmd.replace('$1', f'"{seed_path}"')
            test_logger.info(f"Starting seed: {seed_name}")
            test_logger.info(f"Seed file: {seed_path}")
            test_logger.info(f"Command: {command}")
            test_logger.info(f"Working directory: {dut_config.emu_path}")
            
            seed_logger.info("==== TEST OUTPUT BEGIN ====")
            result = subprocess.run(
                command, 
                shell=True,
                cwd=dut_config.emu_path,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                timeout=300
            )
            # Save output
            seed_logger.info(result.stdout)
            seed_logger.info("==== TEST OUTPUT END ====")
            
            # Parse result
            if result.returncode == 0:
                result_type = ResultType.SUCCESS
                summary = "No differences to reference and no errors"
            else:
                result_type = ResultType.FAILURE
                summary = f"Exited with code {result.returncode}"
            
            seed_logger.info(f"Test completed with status: {result_type.name}")
            test_logger.info(f"Seed completed: {seed_name} - Status: {result_type.name}")
            
            return TestResult(
                dut_name=dut_config.name,
                version=dut_config.version,
                diff_ref=dut_config.diff_ref,
                seed_name=seed_name,
                result_type=result_type,
                summary=summary,
                log_path=seed_log_path
            )
            
        except subprocess.TimeoutExpired as e:
            error_msg = f"Test timed out after 300 seconds: {seed_name}"
            seed_logger.error(error_msg)
            return TestResult(
                dut_name=dut_config.name,
                version=dut_config.version,
                diff_ref=dut_config.diff_ref,
                seed_name=seed_name,
                result_type=ResultType.TIMEOUT,
                summary="Timeout expired (300s)",
                log_path=seed_log_path
            )
        except Exception as e:
            error_msg = f"Unexpected error during test execution: {e} - Seed: {seed_name}"
            seed_logger.exception(error_msg)
            return TestResult(
                dut_name=dut_config.name,
                version=dut_config.version,
                diff_ref=dut_config.diff_ref,
                seed_name=seed_name,
                result_type=ResultType.ERROR,
                summary=f"Unexpected error: {str(e)}",
                log_path=seed_log_path
            )
        finally:
            # Clean up logger handlers
            for hdlr in seed_logger.handlers[:]:
                hdlr.close()
                seed_logger.removeHandler(hdlr)


def run_single_test(dut_config: DUTTarget, seed_config: SeedConfigBase, config_filename: str, global_logger: logging.Logger = logger) -> list[TestResult]:
    """Execute a single test configuration with potential multiple seeds"""
    results = []
    
    with create_test_logger(seed_config.name, config_filename) as (test_logger, log_file_path):
        test_logger.info(f"Starting test: {dut_config.name} with seed config: {seed_config.name}")
        test_logger.info(f"DUT version: {dut_config.version}")
        test_logger.info(f"Diff reference: {dut_config.diff_ref}")
        
        # Collect all seed files for this configuration
        seed_files = []
        try:
            # Handle directory-based seeds
            if isinstance(seed_config, DirSeedConfig):
                test_logger.info(f"Seed mode: dir (path: {seed_config.path}, suffix: {seed_config.suffix})")
                suffix = f"*.{seed_config.suffix}" if seed_config.suffix else "*"
                pattern = os.path.join(seed_config.path, "**", suffix)
                seed_files = glob.glob(pattern, recursive=True)
                test_logger.info(f"Found {len(seed_files)} seed files in directory")
                
            # Handle generated seeds (like divefuzz)
            elif isinstance(seed_config, GeneratedSeedConfig):
                test_logger.info(f"Seed mode: {seed_config.input_type}")
                if seed_config.input_type == "divefuzz":
                    setup_divefuzz(seed_config, global_logger=test_logger)
                    seed_files = run_divefuzz(seed_config, test_logger)
                    test_logger.info(f"Generated {len(seed_files)} seed files via divefuzz")
                else:
                    test_logger.error(f"Unsupported seed input type: {seed_config.input_type}")
                    return []
            
            # Handle single seed file path
            else:
                test_logger.info(f"Seed mode: single file (path: {seed_config.path})")
                seed_files = [seed_config.path]
            
            if not seed_files:
                test_logger.warning("No seed files found for test configuration!")
                return []
                
        except Exception as e:
            global_logger.exception(f"Error preparing seeds: {e}")
            return []
        
        # Run seeds in parallel using ThreadPoolExecutor
        global_logger.info(f"Running {len(seed_files)} seed(s) with {dut_config.threads} threads")
        with ThreadPoolExecutor(max_workers=dut_config.threads) as executor:
            futures = {
                executor.submit(
                    run_single_seed,
                    seed_path,
                    f"{seed_config.name}_{os.path.basename(seed_path)}",
                    dut_config,
                    seed_config.name,
                    test_logger
                ): seed_path
                for seed_path in seed_files
            }
            
            for future in as_completed(futures):
                seed_path = futures[future]
                try:
                    result = future.result()
                    results.append(result)
                    generate_result_report(result, global_logger)
                except Exception as e:
                    error_msg = f"Unexpected error processing seed {seed_path}: {e}"
                    test_logger.exception(error_msg)
                    global_logger.exception(error_msg)
        
        return results


def run_dut_tests(config: Config, config_filename: str, feedback: dict | None = None) -> list[TestResult]:
    """Run all tests defined in the configuration.

    If feedback dict is provided, runs the RVFUZZ feedback-guided loop.
    Otherwise falls back to original DiveFuzz batch behavior.
    """
    if feedback is not None:
        return _run_dut_tests_with_feedback(config, config_filename, feedback)
    return _run_dut_tests_original(config, config_filename)


def _run_dut_tests_original(config: Config, config_filename: str) -> list[TestResult]:
    """Original DiveFuzz batch execution (no feedback loop)."""
    total_results = []
    
    logger.info(f"Starting tests for DUT: {config.dut_target.name}")
    logger.info(f"Number of seed configurations: {len(config.seeds)}")
    logger.info(f"Parallel threads per configuration: {config.dut_target.threads}")
    # Start time
    start_time = datetime.now()
    logger.info(f"Start time: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Run all seed configurations
    for seed_config in config.seeds:
        logger.info(f"Running seed configuration: {seed_config.name}")
        results = run_single_test(
            dut_config=config.dut_target,
            seed_config=seed_config,
            config_filename=config_filename,
            global_logger=logger
        )
        total_results.extend(results)
    
    # End time
    end_time = datetime.now()
    logger.info(f"End time: {end_time.strftime('%Y-%m-%d %H:%M:%S')}")
    # Format Duration
    duration_text = format_duration(start_time, end_time)
    
    # Generate summary report
    passed = sum(1 for r in total_results if r.result_type == ResultType.SUCCESS)
    failed = sum(1 for r in total_results if r.result_type == ResultType.FAILURE)
    timeouts = sum(1 for r in total_results if r.result_type == ResultType.TIMEOUT)
    errors = sum(1 for r in total_results if r.result_type == ResultType.ERROR)
    total = len(total_results)
    
    generate_summary_report(
        dut_name=f"{config.dut_target.name} ({config.dut_target.diff_ref}) {config.dut_target.version}",
        total_seeds=total,
        passed=passed,
        failed=failed,
        issues=timeouts + errors,
        logger=logger
    )
    
    logger.info(
        f"Testing completed: {passed} passed, {failed} failed, "
        f"{timeouts} timed out, {errors} errors. Total: {total}. Duration: {duration_text}"
    )
    
    return total_results


# ---------------------------------------------------------------------------
# RVFUZZ Feedback Loop — Manager-Worker batch loop (multiprocess implant)
# ---------------------------------------------------------------------------

def _run_dut_tests_with_feedback(config: Config, config_filename: str,
                                 feedback: dict) -> list[TestResult]:
    """Manager-Worker batch fuzzing loop (RVFUZZ multiprocess implant)."""
    from concurrent.futures import ProcessPoolExecutor, as_completed
    from fuzzer.core.sync import SyncDecisionEngine
    from fuzzer.core.fitness import FitnessCalculator
    from fuzzer.model.result import ExecuteResult
    from fuzzer.executor.worker import worker_entry

    corpus = feedback["corpus"]
    scheduler = feedback["scheduler"]
    signal_extractor = feedback["signal_extractor"]
    decision_policy = feedback["decision_policy"]
    sync_engine = SyncDecisionEngine()
    fitness_calc = FitnessCalculator()

    M = max(1, config.dut_target.threads)
    output_dir = ((Path(config.corpus_dir) / "seeds").resolve() if config.corpus_dir
                  else Path("outputs").resolve() / "seeds")
    output_dir.mkdir(parents=True, exist_ok=True)

    # Extract seed config params
    seed_config = config.seeds[0]
    if not isinstance(seed_config, GeneratedSeedConfig):
        logger.error("Feedback loop requires a GeneratedSeedConfig")
        return []

    setup_divefuzz(seed_config, global_logger=logger)
    from fuzzer.executor.divefuzz_adapter import _divefuzz_config
    arch = _divefuzz_config.arch
    allowed_ext_name = _divefuzz_config.allowed_ext_name
    instr_number = seed_config.divefuzz.ins_num
    template_type = seed_config.divefuzz.template_type
    architecture = seed_config.divefuzz.architecture
    dive_enable = seed_config.divefuzz.dive_enable
    is_rv32 = seed_config.divefuzz.is_rv32

    # --- Warmup ---
    if len(scheduler) == 0:
        logger.info("[RVFUZZ] Scheduler empty — warmup generating %d seeds", M)
        for _ in range(M):
            sid = _allocate_seed_id(corpus)
            scheduler.push(SeedRef(sid, "exploration", score=0.5, action="generate"))
        warmup_batch = scheduler.pop_best(M)
        warmup_tasks = [
            WorkerTask(
                seed_ref=ref,
                output_dir=output_dir,
                emu_cmd=config.dut_target.cmd,
                emu_path=config.dut_target.emu_path,
                arch=arch,
                instr_number=instr_number,
                template_type=template_type,
                architecture=architecture,
                dive_enable=dive_enable,
                is_rv32=is_rv32,
                allowed_ext_name=allowed_ext_name,
                bug_filter_arch=architecture,
            )
            for ref in warmup_batch
        ]
        with ProcessPoolExecutor(max_workers=M) as pool:
            futures = {pool.submit(worker_entry, t): t for t in warmup_tasks}
            warmup_results = [fut.result() for fut in as_completed(futures)]
        # Build result map
        warmup_result_map = {r.seed_id: r for r in warmup_results}
        snapshot = corpus.snapshot()
        for task in warmup_tasks:
            result = warmup_result_map.get(task.seed_ref.seed_id)
            if result is None:
                continue
            _evaluate_and_enqueue(
                task, result, corpus, scheduler, signal_extractor,
                decision_policy, sync_engine, fitness_calc, snapshot,
            )

    # --- Main loop ---
    total_iter = 0
    while total_iter < config.batch_size and len(scheduler) > 0:
        snapshot = corpus.snapshot()

        # Fill queue if needed
        if len(scheduler) < M:
            needed = M - len(scheduler)
            for _ in range(needed):
                sid = _allocate_seed_id(corpus)
                scheduler.push(SeedRef(sid, "exploration", score=0.5, action="generate"))

        batch = scheduler.pop_best(M)
        logger.info("[RVFUZZ] Batch %d: dispatching %d seeds", total_iter, len(batch))

        tasks = [
            WorkerTask(
                seed_ref=ref,
                output_dir=output_dir,
                emu_cmd=config.dut_target.cmd,
                emu_path=config.dut_target.emu_path,
                arch=arch,
                instr_number=instr_number,
                template_type=template_type,
                architecture=architecture,
                dive_enable=dive_enable,
                is_rv32=is_rv32,
                allowed_ext_name=allowed_ext_name,
                bug_filter_arch=architecture,
            )
            for ref in batch
        ]

        with ProcessPoolExecutor(max_workers=M) as pool:
            futures = {pool.submit(worker_entry, t): t for t in tasks}
            results = []
            for fut in as_completed(futures):
                try:
                    results.append(fut.result())
                except Exception as exc:
                    task = futures[fut]
                    logger.error("[RVFUZZ] Worker failed for seed %s: %s",
                                 task.seed_ref.seed_id, exc)
                    # If mutation keeps failing, fall back to generate
                    fallback_action = task.seed_ref.action
                    if fallback_action == "mutate":
                        fallback_action = "generate"
                    scheduler.push(SeedRef(task.seed_ref.seed_id, "exploration", 0.1,
                                           lineage_parent=task.seed_ref.lineage_parent,
                                           action=fallback_action))

        result_map = {r.seed_id: r for r in results}

        # First pass: score against snapshot
        for task in tasks:
            result = result_map.get(task.seed_ref.seed_id)
            if result is None:
                continue
            _evaluate_and_enqueue(
                task, result, corpus, scheduler, signal_extractor,
                decision_policy, sync_engine, fitness_calc, snapshot,
            )

        # Persist
        persist_dir = output_dir.parent
        corpus.dump_campaign_state(persist_dir / "campaign_state.json")
        scheduler.dump_queue(persist_dir / "queue_state.json")
        total_iter += 1

    logger.info("[RVFUZZ] Feedback loop complete. Iterations: %d", total_iter)
    return []


def _evaluate_and_enqueue(
    task: WorkerTask, result: WorkerResult, corpus, scheduler,
    signal_extractor, decision_policy, sync_engine, fitness_calc,
    snapshot: set[str],
) -> None:
    """Score a single result against snapshot, update corpus, re-enqueue."""
    from fuzzer.model.result import ExecuteResult

    delta = corpus.preview_delta_from_snapshot(snapshot, result.transitions)

    # Sync classification
    sync_summary = sync_engine.summary(
        sync_engine.classify([{"family": f, "cov": ""} for f in result.diff_families])
    )

    # Diff novelty
    diff_delta = corpus.preview_diff_delta(result.diff_families)
    diff_novelty = (len(diff_delta["new_families"]) /
                    max(len(set(result.diff_families)), 1)
                    if result.diff_families else 0.0)

    # Signal extraction
    signals = signal_extractor.extract(
        status=result.status,
        failure_kind=result.failure_kind,
        coverage_new_points=delta["new_coverage"],
        coverage_total_points=delta["total_coverage"],
        category_deltas=delta["by_category"],
        transition_rarities=corpus.get_category_rarities(),
        diff_novelty_score=diff_novelty,
        syncable_count=sync_summary["syncable_count"],
    )

    # Fitness
    parent_fitness = corpus.get_seed_fitness(task.seed_ref.lineage_parent or "")
    fitness = fitness_calc.evaluate(
        seed=result.seed_id,
        category_deltas=delta["by_category"],
        diff_families=result.diff_families,
        exploration_value=signals.exploration_value,
        lineage_depth=parent_fitness.get("lineage_depth", 0) + 1 if isinstance(parent_fitness, dict) else 0,
    )
    corpus.update_seed_fitness(result.seed_id, fitness)

    # Tag seed for GoalDirectedScheduler
    dom_cat = fitness_calc.dominant_category(delta["by_category"])
    scheduler.tag_seed(result.seed_id, dom_cat)
    scheduler.update_saturation(delta["by_category"])

    # Record to corpus
    corpus.record_transitions(result.transitions)
    if result.diff_families:
        corpus.record_diff_families(result.diff_families, result.seed_id)

    exec_result = ExecuteResult(
        case_id=result.seed_id,
        status=result.status,
        csr_transitions=result.transitions,
        diff_families=result.diff_families,
        syncable_count=sync_summary["syncable_count"],
        potential_bug_count=sync_summary["potential_bug_count"],
    )
    bundle = _build_bundle(task.seed_ref, result, exec_result)
    decision = decision_policy.decide(signals)
    bundle["feedback_decision"] = decision.decision
    corpus.record(bundle)

    score = fitness.exploration_score

    # Re-enqueue based on decision
    if decision.decision == "promote_mutation":
        scheduler.push(SeedRef(result.seed_id, decision.queue, score,
                               lineage_parent=result.seed_id,
                               action=task.seed_ref.action))
        # Schedule mutation for next batch
        mutated_id = _allocate_seed_id(corpus)
        scheduler.push(SeedRef(mutated_id, "stable_ancestor", score,
                               lineage_parent=result.seed_id, action="mutate"))
    elif decision.decision == "keep_in_corpus":
        scheduler.push(SeedRef(result.seed_id, "exploration", score,
                               lineage_parent=result.seed_id,
                               action=task.seed_ref.action))
    # archive_only / discard → not re-enqueued


def run_single_seed_with_observation(
    seed_path: str, seed_name: str, dut_config: DUTTarget,
    seed_config_name: str,
) -> TestResult:
    """Run a single seed and capture difftest observation output.

    Extends run_single_seed() by:
    - Appending --rvfuzz-observe / --rvfuzz-observe-level to the emu command
    - Resolving the observe_path from the DUT working directory and
      attaching it to the result.
    """
    observe_rel = getattr(dut_config, 'observe_path', '') or 'difftest.observe.jsonl'
    observe_level = getattr(dut_config, 'observe_level', '') or 'all'

    # Append rvfuzz-observe flags to the emu command so the emulator
    # writes observation JSONL during execution.
    original_cmd = dut_config.cmd
    observe_flag = f" --rvfuzz-observe={observe_rel} --rvfuzz-observe-level={observe_level}"
    if "--rvfuzz-observe=" not in original_cmd:
        dut_config.cmd = original_cmd + observe_flag

    try:
        result = run_single_seed(seed_path, seed_name, dut_config, seed_config_name, logger)
    finally:
        dut_config.cmd = original_cmd

    # Resolve observation path from DUT working directory
    observe_path = Path(dut_config.emu_path) / observe_rel
    if observe_path.exists():
        result.observation_path = observe_path
        logger.info(f"[RVFUZZ] Observation file: {observe_path}")
    else:
        result.observation_path = None

    return result
