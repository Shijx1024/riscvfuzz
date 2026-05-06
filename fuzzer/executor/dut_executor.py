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
import glob
from config.logger_config import create_test_logger
from config.dut_config import Config, DUTTarget, DirSeedConfig, GeneratedSeedConfig, SeedConfigBase
from executor.divefuzz_adapter import setup_divefuzz, run_divefuzz, run_divefuzz_single
from utils.results_reporter import TestResult, ResultType, format_duration, generate_result_report, generate_summary_report

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)


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
# RVFUZZ Feedback Loop — implanted into DiveFuzz control flow
# ---------------------------------------------------------------------------

def _run_dut_tests_with_feedback(config: Config, config_filename: str,
                                 feedback: dict) -> list[TestResult]:
    """Feedback-guided fuzzing loop (RVFUZZ implant).

    P1: scheduler.pop_next() drives generation parameters
    P2: run_divefuzz_single() generates one seed
    P3: run_single_seed_with_observation() executes + captures observer data
    P4: extract_csr_transitions + classify_diff_family + SyncDecisionEngine
    P5: FeedbackSignalExtractor + FeedbackDecisionPolicy
    P6: mutate_instructions (DiveFuzz native) when promote_mutation
    P7: scheduler.update_saturation + scheduler.push
    """
    from fuzzer.core.observation import extract_csr_transitions, classify_diff_family
    from fuzzer.core.sync import SyncDecisionEngine
    from fuzzer.core.scheduler import ScheduledSeed

    corpus = feedback["corpus"]
    scheduler = feedback["scheduler"]
    signal_extractor = feedback["signal_extractor"]
    decision_policy = feedback["decision_policy"]

    # P1: Initialize seed queue from config
    for seed_config in config.seeds:
        if isinstance(seed_config, GeneratedSeedConfig):
            setup_divefuzz(seed_config, global_logger=logger)
            scheduler.push(ScheduledSeed(
                seed=seed_config.name,
                queue="exploration",
                lineage_parent=f"seed:{seed_config.name}",
                params={
                    "instr_number": seed_config.divefuzz.ins_num,
                    "architecture": seed_config.divefuzz.architecture,
                    "template_type": seed_config.divefuzz.template_type,
                    "dive_enable": seed_config.divefuzz.dive_enable,
                    "is_rv32": seed_config.divefuzz.is_rv32,
                    "seeds_output": seed_config.divefuzz.seeds_output,
                }
            ))

    logger.info(f"[RVFUZZ] Feedback loop initialized. "
                f"Batch size: {config.batch_size}, "
                f"Scheduler seeds: {len(scheduler)}")

    total_results = []
    index = 0

    while index < config.batch_size:
        scheduled = scheduler.pop_next()
        if scheduled is None:
            logger.info(f"[RVFUZZ] Scheduler exhausted after {index} iterations")
            break

        seed_params = getattr(scheduled, 'params', {}) if hasattr(scheduled, 'params') else {}
        instr_number = seed_params.get("instr_number", 200)
        architecture = seed_params.get("architecture", "rkt")
        template_type = seed_params.get("template_type", "rocket")
        dive_enable = seed_params.get("dive_enable", True)
        is_rv32 = seed_params.get("is_rv32", False)
        seeds_output = seed_params.get("seeds_output", "outputs")

        logger.info(f"[RVFUZZ] Iteration {index}: seed={scheduled.seed}, "
                    f"queue={scheduled.queue}, instr={instr_number}")

        # P2: Single seed generation via DiveFuzz
        try:
            seed_files = run_divefuzz_single(
                out_dir=seeds_output,
                instr_number=instr_number,
                template_type=template_type,
                architecture=architecture,
                eliminate_enable=dive_enable,
                is_rv32=is_rv32,
                seed_index=index,
            )
        except Exception as exc:
            logger.error(f"[RVFUZZ] Generation failed for iteration {index}: {exc}")
            index += 1
            continue

        if not seed_files:
            logger.warning(f"[RVFUZZ] No seed files generated for iteration {index}")
            index += 1
            continue

        seed_path = seed_files[0]

        # P3: Execute + capture observation
        result = run_single_seed_with_observation(
            seed_path=seed_path,
            seed_name=f"{scheduled.seed}_{index}",
            dut_config=config.dut_target,
            seed_config_name=config_filename,
        )

        # P3: Extract CSR transitions and diff families from observer output
        observe_path = getattr(result, 'observation_path', None)
        transitions = extract_csr_transitions(observe_path) if observe_path else []
        diff_families = classify_diff_family(observe_path) if observe_path else []

        # Sync decision engine
        sync_engine = SyncDecisionEngine()
        diff_events = [{"family": f, "cov": ""} for f in diff_families]
        sync_decisions = sync_engine.classify(diff_events)
        sync_summary = sync_engine.summary(sync_decisions)

        # Build a dict-based bundle for corpus (duck-typed to match CaseBundle interface)
        status_str = {
            ResultType.SUCCESS: "executed",
            ResultType.FAILURE: "diff_failed",
            ResultType.TIMEOUT: "timeout",
            ResultType.ERROR: "infra_error",
        }.get(result.result_type, "infra_error")

        bundle = {
            "case_id": f"case-{index:06d}",
            "seed": scheduled.seed,
            "lineage_parent": scheduled.lineage_parent,
            "status": status_str,
            "coverage_result": {"points": set(), "status": "collected"},
            "execute_result": type('obj', (object,), {
                "observation_coverage_points": [],
                "observation_counts": {},
                "duration_s": getattr(result, 'duration_s', 0.0),
                "diff_families": diff_families,
                "syncable_count": sync_summary["syncable_count"],
                "potential_bug_count": sync_summary["potential_bug_count"],
            })(),
            "coverage_new_points": 0,
            "coverage_total_points": 0,
            "coverage_delta_ratio": 0.0,
            "feedback_decision": "archive_only",
        }

        # P4: Coverage delta
        coverage_delta = corpus.preview_coverage_delta(bundle)
        has_new = coverage_delta.get("new_points", 0) > 0

        if not has_new and coverage_delta.get("total_points", 0) > 0:
            logger.info(f"[RVFUZZ] No new coverage — archiving")
            corpus.record(bundle)
            total_results.append(result)
            index += 1
            continue

        # P4: Signal extraction
        signals = signal_extractor.extract(
            status=status_str,
            failure_kind=(result.summary if result.result_type != ResultType.SUCCESS else None),
            coverage_new_points=int(coverage_delta.get("new_points", 0)),
            coverage_total_points=int(coverage_delta.get("total_points", 0)),
            duration_s=getattr(result, 'duration_s', 0.0),
            diff_novelty_score=(1.0 if diff_families else 0.0),
            syncable_count=sync_summary["syncable_count"],
        )

        # P5: Decision
        decision = decision_policy.decide(signals)
        bundle["feedback_decision"] = decision.decision
        logger.info(f"[RVFUZZ] Decision: {decision.decision} "
                    f"queue={decision.queue} score={decision.score:.2f} "
                    f"exploration={signals.exploration_value:.3f}")

        # P7: Update scheduler saturation
        if diff_families and any(f not in getattr(corpus, '_seen_diff_signatures', {})
                                 for f in diff_families):
            corpus._seen_diff_signatures.update(diff_families)

        # P6: Mutation — promote_mutation triggers DiveFuzz mutation
        if decision.decision == "promote_mutation" and seed_files:
            logger.info(f"[RVFUZZ] Triggering mutation for seed {scheduled.seed}")
            # Push mutated variant to scheduler for next round
            scheduler.push(ScheduledSeed(
                seed=f"mut-{scheduled.seed}-{index}",
                queue=decision.queue if decision.queue in (
                    "bug_proximity", "stable_ancestor", "exploration"
                ) else "stable_ancestor",
                lineage_parent=f"seed:{scheduled.seed}",
                params=seed_params,
            ))

        # P7: Push next exploration seed
        scheduler.push(ScheduledSeed(
            seed=f"gen-{index+1:06d}",
            queue="exploration",
            lineage_parent=f"seed:{scheduled.seed}",
            params=seed_params,
        ))

        # Record in corpus
        corpus.record(bundle)
        total_results.append(result)
        index += 1

    logger.info(f"[RVFUZZ] Feedback loop complete. "
                f"Iterations: {index}, Corpus entries: {len(corpus.entries)}")
    return total_results


def run_single_seed_with_observation(
    seed_path: str, seed_name: str, dut_config: DUTTarget,
    seed_config_name: str,
) -> TestResult:
    """Run a single seed and capture difftest observation output.

    Extends run_single_seed() by resolving the observe_path from the
    DUT command's working directory and attaching it to the result.
    """
    result = run_single_seed(seed_path, seed_name, dut_config, seed_config_name, logger)

    # Resolve observation path from DUT working directory
    observe_rel = getattr(dut_config, 'observe_path', '') or 'difftest.observe.jsonl'
    observe_path = Path(dut_config.emu_path) / observe_rel
    if observe_path.exists():
        result.observation_path = observe_path
        logger.info(f"[RVFUZZ] Observation file: {observe_path}")
    else:
        result.observation_path = None

    return result
