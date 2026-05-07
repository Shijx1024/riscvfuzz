"""Integration tests for RVFUZZ feedback loop implanted in DiveFuzz."""

import heapq
import json
import tempfile
from pathlib import Path
from unittest.mock import patch, MagicMock

import pytest


class TestScheduler:
    def test_push_and_pop_priority_order(self):
        from fuzzer.core.scheduler import GoalDirectedScheduler
        from fuzzer.core.seed_ref import SeedRef

        scheduler = GoalDirectedScheduler()
        scheduler.push(SeedRef(seed_id="s1", queue="exploration"))
        scheduler.push(SeedRef(seed_id="s2", queue="bug_proximity"))
        scheduler.push(SeedRef(seed_id="s3", queue="stable_ancestor"))

        # bug_proximity has highest priority
        first = scheduler.pop_next()
        assert first.seed_id == "s2"
        assert first.queue == "bug_proximity"

        # exploration next
        second = scheduler.pop_next()
        assert second.seed_id == "s1"

        # stable_ancestor last
        third = scheduler.pop_next()
        assert third.seed_id == "s3"

        assert scheduler.pop_next() is None

    def test_duplicate_seeds_rejected(self):
        from fuzzer.core.scheduler import GoalDirectedScheduler
        from fuzzer.core.seed_ref import SeedRef

        scheduler = GoalDirectedScheduler()
        assert scheduler.push(SeedRef(seed_id="dup", queue="exploration")) is True
        assert scheduler.push(SeedRef(seed_id="dup", queue="bug_proximity")) is False
        assert len(scheduler) == 1

    def test_saturation_boost_reorders_queue(self):
        from fuzzer.core.scheduler import GoalDirectedScheduler
        from fuzzer.core.seed_ref import SeedRef

        scheduler = GoalDirectedScheduler()
        # Tag a seed with "memory" category
        scheduler.tag_seed("s1", "memory")
        scheduler.push(SeedRef(seed_id="s1", queue="exploration"))
        scheduler.push(SeedRef(seed_id="s2", queue="exploration"))

        # Without saturation boost, s1 comes first (heapq by score, tie=0.0)
        first = scheduler.pop_next()
        assert first.seed_id == "s1"

        # Now push more seeds and update saturations so that "memory" is the
        # lowest-saturation category.  All categories default to 0.0, so we
        # must update every category — any category left at 0.0 will be chosen
        # as the target instead of "memory".
        scheduler.tag_seed("s3", "memory")
        scheduler.push(SeedRef(seed_id="s3", queue="exploration"))
        scheduler.push(SeedRef(seed_id="s4", queue="exploration"))

        # Give every category total > 0 so saturation is computed for all.
        # memory: new=5,total=10  → novelty_rate=0.5 → saturation=0.25 (<0.3)
        # others: new=0,total=10  → novelty_rate=0.0 → saturation=0.50 (>0.3)
        scheduler.update_saturation({
            "privilege": {"new": 0, "total": 10},
            "float":     {"new": 0, "total": 10},
            "control":   {"new": 0, "total": 10},
            "memory":    {"new": 5, "total": 10},
            "counter":   {"new": 0, "total": 10},
            "misc":      {"new": 0, "total": 10},
        })

        # s3 should be boosted ahead of s4 due to low memory saturation
        boosted = scheduler.pop_next()
        assert boosted.seed_id == "s3"

    def test_pop_next_exhausted_returns_none(self):
        from fuzzer.core.scheduler import GoalDirectedScheduler
        scheduler = GoalDirectedScheduler()
        assert scheduler.pop_next() is None

    def test_pop_best_weighted_distribution(self):
        from fuzzer.core.seed_ref import SeedRef
        from fuzzer.core.scheduler import GoalDirectedScheduler
        s = GoalDirectedScheduler()
        for i in range(10):
            s.push(SeedRef(f"e{i:02d}", "exploration", score=float(i) / 10.0))
        for i in range(5):
            s.push(SeedRef(f"s{i:02d}", "stable_ancestor", score=float(i) / 5.0))
        for i in range(3):
            s.push(SeedRef(f"b{i:02d}", "bug_proximity", score=1.0))
        batch = s.pop_best(6)
        assert len(batch) <= 6
        queues = [r.queue for r in batch]
        assert "bug_proximity" in queues

    def test_pop_best_exhausted_returns_partial(self):
        from fuzzer.core.seed_ref import SeedRef
        from fuzzer.core.scheduler import GoalDirectedScheduler
        s = GoalDirectedScheduler()
        s.push(SeedRef("s1", "exploration", score=0.5))
        batch = s.pop_best(10)
        assert len(batch) == 1

    def test_dump_and_restore_queue(self, tmp_path):
        from fuzzer.core.seed_ref import SeedRef
        from fuzzer.core.scheduler import GoalDirectedScheduler
        s = GoalDirectedScheduler()
        s.push(SeedRef("s1", "exploration", score=0.8, lineage_parent="p1", action="generate"))
        s.push(SeedRef("s2", "bug_proximity", score=1.0, action="mutate"))
        path = tmp_path / "queue_state.json"
        s.dump_queue(path)
        assert path.exists()
        s2 = GoalDirectedScheduler()
        s2.restore(path)
        popped = s2.pop_next()
        assert popped is not None
        assert popped.seed_id in {"s1", "s2"}


class TestFeedbackSignals:
    def test_signal_extraction_with_new_coverage(self):
        from fuzzer.core.feedback_loop import FeedbackSignalExtractor

        extractor = FeedbackSignalExtractor()
        signals = extractor.extract(
            status="executed",
            failure_kind=None,
            coverage_new_points=5,
            coverage_total_points=10,
        )
        assert signals.status == "executed"
        assert signals.coverage_new_points == 5
        assert signals.exploration_value > 0
        assert signals.diff_novelty_score == 0.0

    def test_signal_extraction_with_diff(self):
        from fuzzer.core.feedback_loop import FeedbackSignalExtractor

        extractor = FeedbackSignalExtractor()
        signals = extractor.extract(
            status="diff_failed",
            failure_kind="diff_mismatch",
            coverage_new_points=0,
            coverage_total_points=5,
            diff_novelty_score=1.0,
            syncable_count=2,
        )
        assert signals.diff_novelty_score == 1.0
        assert signals.syncable_count == 2
        assert signals.exploration_value >= 0.5  # boosted by diff novelty

    def test_signal_extraction_no_coverage(self):
        from fuzzer.core.feedback_loop import FeedbackSignalExtractor

        extractor = FeedbackSignalExtractor()
        signals = extractor.extract(
            status="executed",
            failure_kind=None,
            coverage_new_points=0,
            coverage_total_points=0,
        )
        assert signals.coverage_new_points == 0
        assert signals.exploration_value == 0.0


class TestDecisionPolicy:
    def test_diff_failed_promotes_mutation_bug_proximity(self):
        from fuzzer.core.feedback_loop import FeedbackDecisionPolicy, FeedbackSignals

        policy = FeedbackDecisionPolicy()
        signals = FeedbackSignals(
            status="diff_failed", failure_kind="diff_mismatch",
            coverage_new_points=0, coverage_total_points=0,
            exploration_value=0.8,
            diff_novelty_score=1.0,
        )
        decision = policy.decide(signals)
        assert decision.decision == "promote_mutation"
        assert decision.queue == "bug_proximity"

    def test_executed_with_new_coverage_promotes_mutation_stable(self):
        from fuzzer.core.feedback_loop import FeedbackDecisionPolicy, FeedbackSignals

        policy = FeedbackDecisionPolicy()
        signals = FeedbackSignals(
            status="executed", failure_kind=None,
            coverage_new_points=3, coverage_total_points=10,
            exploration_value=0.5,
        )
        decision = policy.decide(signals)
        assert decision.decision == "promote_mutation"
        assert decision.queue == "stable_ancestor"

    def test_executed_no_new_coverage_keep_in_corpus(self):
        from fuzzer.core.feedback_loop import FeedbackDecisionPolicy, FeedbackSignals

        policy = FeedbackDecisionPolicy()
        signals = FeedbackSignals(
            status="executed", failure_kind=None,
            coverage_new_points=0, coverage_total_points=10,
            exploration_value=0.0,
        )
        decision = policy.decide(signals)
        assert decision.decision == "keep_in_corpus"


class TestRunCorpus:
    def test_record_and_dedup(self):
        from fuzzer.core.corpus import RunCorpus
        from fuzzer.core.status import CaseStatus

        corpus = RunCorpus(max_retained=100)
        bundle1 = {
            "case_id": "case-1",
            "seed": "s1",
            "coverage_result": {"points": {"cov:a", "cov:b"}, "status": "collected"},
            "execute_result": {
                "status": CaseStatus.EXECUTED,
                "failure_kind": None,
                "message": "",
                "image_path": None,
            },
        }
        corpus.record(bundle1)
        assert len(corpus.entries) == 1
        assert corpus.entries[0].decision == "promote_mutation"

        # Same coverage + same status/message → same signature → dedup
        bundle2 = {
            "case_id": "case-2",
            "seed": "s2",
            "coverage_result": {"points": {"cov:a", "cov:b"}, "status": "collected"},
            "execute_result": {
                "status": CaseStatus.EXECUTED,
                "failure_kind": None,
                "message": "",
                "image_path": None,
            },
        }
        corpus.record(bundle2)
        assert len(corpus.entries) == 2
        assert corpus.entries[1].decision == "archive_only"

    def test_dump_and_load_state(self):
        from fuzzer.core.corpus import RunCorpus
        from fuzzer.core.status import CaseStatus

        corpus = RunCorpus(max_retained=100)
        corpus.record({
            "case_id": "case-1",
            "seed": "s1",
            "coverage_result": {"points": {"cov:a"}, "status": "collected"},
            "execute_result": {
                "status": CaseStatus.EXECUTED,
                "failure_kind": None,
                "message": "",
                "image_path": None,
            },
        })

        with tempfile.TemporaryDirectory() as tmp:
            state_path = Path(tmp) / "corpus_state.json"
            corpus.dump_state(state_path)
            assert state_path.exists()

            payload = json.loads(state_path.read_text())
            assert payload["total_recorded"] == 1

    def test_preview_coverage_delta(self):
        from fuzzer.core.corpus import RunCorpus
        from fuzzer.core.status import CaseStatus

        corpus = RunCorpus(max_retained=100)

        bundle = {
            "case_id": "case-1",
            "seed": "s1",
            "coverage_result": {"points": {"cov:new1", "cov:new2"}, "status": "collected"},
            "execute_result": {
                "status": CaseStatus.EXECUTED,
                "failure_kind": None,
                "message": "",
                "image_path": None,
            },
        }
        delta = corpus.preview_coverage_delta(bundle)
        assert delta["new_points"] == 2
        assert delta["total_points"] == 2

        # record() updates seen coverage; same points then appear as 0 new
        corpus.record(bundle)

        delta2 = corpus.preview_coverage_delta(bundle)
        assert delta2["new_points"] == 0
        assert delta2["total_points"] == 2

    def test_snapshot_returns_copy(self):
        from fuzzer.core.corpus import RunCorpus
        corpus = RunCorpus()
        corpus._seen_coverage_points.add("privilege|csrrs")
        snap = corpus.snapshot()
        assert "privilege|csrrs" in snap
        corpus._seen_coverage_points.add("float|fadd.s")
        assert "float|fadd.s" not in snap  # snapshot is frozen

    def test_preview_delta_from_snapshot(self):
        from fuzzer.core.corpus import RunCorpus
        corpus = RunCorpus()
        corpus._seen_coverage_points.add("privilege|csrrs")
        snap = corpus.snapshot()
        transitions = [
            {"csr": "privilege", "prev_value": "v1", "curr_value": "v2",
             "instr": "csrrs:0x342", "category": "privilege"},
            {"csr": "float", "prev_value": "v3", "curr_value": "v4",
             "instr": "fadd.s:0x53", "category": "float"},
        ]
        delta = corpus.preview_delta_from_snapshot(snap, transitions)
        assert delta["new_coverage"] == 1  # float|fadd.s is new
        assert delta["total_coverage"] == 2

    def test_get_category_rarities(self):
        from fuzzer.core.corpus import RunCorpus
        corpus = RunCorpus()
        corpus._transition_frequency = {
            "privilege|v1|v2|csrrs:0x342": 1,
            "privilege|v3|v4|csrrw:0x123": 8,
            "float|v5|v6|fadd.s:0x53": 1,
        }
        rarities = corpus.get_category_rarities()
        assert "privilege" in rarities
        assert "float" in rarities
        assert 0.3 < rarities["privilege"] < 0.6


class TestSyncDecisionEngine:
    def test_csr_write_syncable(self):
        from fuzzer.core.sync import SyncDecisionEngine

        engine = SyncDecisionEngine()
        events = [{"family": "csr_write", "cov": "csr:mstatus:0x0->0x1:csrw"}]
        decisions = engine.classify(events)
        assert len(decisions) == 1
        assert decisions[0].decision == "syncable"
        assert "FS field" in decisions[0].reason

    def test_fp_rounding_syncable(self):
        from fuzzer.core.sync import SyncDecisionEngine

        engine = SyncDecisionEngine()
        events = [{"family": "fp_rounding", "cov": "csr:fflags:0x0->0x1:fadd.s"}]
        decisions = engine.classify(events)
        assert len(decisions) == 1
        assert decisions[0].decision == "syncable"

    def test_unknown_family_potential_bug(self):
        from fuzzer.core.sync import SyncDecisionEngine

        engine = SyncDecisionEngine()
        events = [{"family": "pc_divergence", "cov": ""}]
        decisions = engine.classify(events)
        assert len(decisions) == 1
        assert decisions[0].decision == "potential_bug"

    def test_summary_counts(self):
        from fuzzer.core.sync import SyncDecisionEngine

        engine = SyncDecisionEngine()
        events = [
            {"family": "fp_rounding", "cov": ""},
            {"family": "csr_write", "cov": "csr:sepc:0x0->0x1:csrw"},
        ]
        decisions = engine.classify(events)
        summary = engine.summary(decisions)
        assert summary["syncable_count"] == 1
        assert summary["potential_bug_count"] == 1


class TestObservation:
    def test_extract_csr_transitions_empty(self):
        from fuzzer.core.observation import extract_csr_transitions

        result = extract_csr_transitions(None)
        assert result == []

    def test_classify_diff_family_empty(self):
        from fuzzer.core.observation import classify_diff_family

        result = classify_diff_family(None)
        assert result == []

    def test_diFF_FAMILIES_covers_7_categories(self):
        from fuzzer.core.observation import DIFF_FAMILIES

        expected = {"fp_rounding", "fp_nan", "csr_write", "trap_difference",
                     "pc_divergence", "memory_ordering", "unknown"}
        assert set(DIFF_FAMILIES.keys()) == expected


class TestStatusEnums:
    def test_case_status_values(self):
        from fuzzer.core.status import CaseStatus

        assert CaseStatus.DIFF_FAILED.value == "diff_failed"
        assert CaseStatus.EXECUTED.value == "executed"
        assert CaseStatus.TIMEOUT.value == "timeout"
        assert CaseStatus.BADTRAP.value == "badtrap"

    def test_failure_kind_values(self):
        from fuzzer.core.status import FailureKind

        assert FailureKind.DIFF_MISMATCH.value == "diff_mismatch"
        assert FailureKind.BAD_TRAP.value == "bad_trap"
        assert FailureKind.INFRA_ERROR.value == "infra_error"
        assert FailureKind.TIMEOUT.value == "timeout"
