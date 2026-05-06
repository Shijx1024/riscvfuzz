from __future__ import annotations

from dataclasses import dataclass

from fuzzer.core.status import CaseStatus

CATEGORY_WEIGHTS: dict[str, float] = {
    "privilege": 1.0,
    "float": 0.8,
    "control": 0.9,
    "memory": 1.2,
    "counter": 0.5,
    "misc": 0.3,
}


@dataclass
class FeedbackSignals:
    status: str
    failure_kind: str | None
    coverage_new_points: int
    coverage_total_points: int
    duration_s: float
    exploration_value: float
    diff_novelty_score: float = 0.0
    syncable_count: int = 0


@dataclass
class FeedbackDecision:
    decision: str
    queue: str
    score: float


class FeedbackSignalExtractor:
    def extract(
        self,
        *,
        status: str,
        failure_kind: str | None,
        coverage_new_points: int,
        coverage_total_points: int,
        duration_s: float,
        category_deltas: dict[str, dict[str, int]] | None = None,
        transition_rarities: dict[str, float] | None = None,
        diff_novelty_score: float = 0.0,
        syncable_count: int = 0,
    ) -> FeedbackSignals:
        if category_deltas:
            exploration_value = 0.0
            total_weight = 0.0
            for cat, delta in category_deltas.items():
                weight = CATEGORY_WEIGHTS.get(cat, 0.3)
                total_weight += weight
                if delta["total"] > 0:
                    rarity = (transition_rarities or {}).get(cat, 1.0)
                    exploration_value += (
                        weight * rarity * (delta["new"] / float(delta["total"]))
                    )
            if total_weight > 0:
                exploration_value = min(1.0, exploration_value / total_weight)
        else:
            ratio = (
                coverage_new_points / float(coverage_total_points)
                if coverage_total_points > 0
                else 0.0
            )
            exploration_value = min(1.0, ratio + (0.2 if coverage_new_points > 0 else 0.0))

        if diff_novelty_score > 0:
            exploration_value = max(exploration_value, 0.5 + 0.5 * diff_novelty_score)

        return FeedbackSignals(
            status=status,
            failure_kind=failure_kind,
            coverage_new_points=coverage_new_points,
            coverage_total_points=coverage_total_points,
            duration_s=duration_s,
            exploration_value=exploration_value,
            diff_novelty_score=diff_novelty_score,
            syncable_count=syncable_count,
        )


class FeedbackDecisionPolicy:
    def decide(self, signals: FeedbackSignals) -> FeedbackDecision:
        status = signals.status
        if status in {
            CaseStatus.DIFF_FAILED.value,
            CaseStatus.REFERENCE_FAILED.value,
            CaseStatus.BADTRAP.value,
            CaseStatus.TIMEOUT.value,
            CaseStatus.COVERAGE_FAILED.value,
        }:
            return FeedbackDecision(decision="promote_mutation", queue="bug_proximity", score=1.0)
        if signals.coverage_new_points > 0 and status == CaseStatus.EXECUTED.value:
            return FeedbackDecision(
                decision="promote_mutation",
                queue="stable_ancestor",
                score=max(0.1, signals.exploration_value),
            )
        if status == CaseStatus.EXECUTED.value:
            return FeedbackDecision(decision="keep_in_corpus", queue="exploration", score=0.2)
        if status == CaseStatus.GENERATED.value:
            return FeedbackDecision(decision="archive_only", queue="exploration", score=0.1)
        return FeedbackDecision(decision="discard", queue="exploration", score=0.0)
