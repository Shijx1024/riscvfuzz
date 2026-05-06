#!/usr/bin/env python3

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

import argparse
import sys
from pathlib import Path
from config.logger_config import get_global_logger, create_output_dir
from config.dut_config import Config
from executor.dut_executor import run_dut_tests
from fuzzer.core.corpus import RunCorpus
from fuzzer.core.scheduler import GoalDirectedScheduler
from fuzzer.core.feedback_loop import FeedbackSignalExtractor, FeedbackDecisionPolicy


def main():
    parser = argparse.ArgumentParser(description="Run DUT tests using seed files")
    parser.add_argument("--config", required=True, help="Path to YAML config file")
    args = parser.parse_args()

    # make sure output dir exists
    create_output_dir()
    global_logger = get_global_logger()
    try:
        # load config
        config = Config.from_yaml(args.config)
        global_logger.info(f"Successfully loaded configuration from {args.config}")

        # [RVFUZZ P0] Initialize feedback loop components
        corpus = RunCorpus(max_retained=config.corpus_max_retained)
        scheduler = GoalDirectedScheduler()
        signal_extractor = FeedbackSignalExtractor()
        decision_policy = FeedbackDecisionPolicy()

        # run tests with feedback loop
        run_dut_tests(config, args.config, feedback={
            "corpus": corpus,
            "scheduler": scheduler,
            "signal_extractor": signal_extractor,
            "decision_policy": decision_policy,
        })

        # [RVFUZZ P8] Persist corpus state
        corpus_dir = Path(config.corpus_dir) if config.corpus_dir else Path("outputs")
        corpus_dir.mkdir(parents=True, exist_ok=True)
        corpus.dump_state(corpus_dir / "corpus_state.json")
        global_logger.info(f"Corpus state saved to {corpus_dir / 'corpus_state.json'}")

    except FileNotFoundError as e:
        global_logger.error(f"Config file not found: {e}")
        return 1

if __name__ == "__main__":
    # sys.exit(main())
    main()
