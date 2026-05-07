from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class SeedFitness:
    seed: str
    category_affinity: dict[str, float] = field(default_factory=dict)
    novelty_score: float = 0.0
    diff_diversity: float = 0.0
    exploration_score: float = 0.0
    lineage_depth: int = 0
    last_active_case: str | None = None


MUTATION_STRATEGIES: dict[str, dict] = {
    "boost_memory": {
        "add_blocks": ["LoadStoreBlock", "AmoBlock"],
        "increase_ratio": 0.3,
    },
    "boost_control": {
        "add_blocks": ["SystemOperationBlock"],
        "branch_retarget": True,
    },
    "boost_privilege": {
        "add_blocks": ["CsrBlock"],
        "csr_target_bias": "privilege_csrs",
    },
    "boost_float": {
        "add_blocks": ["FloatArithmeticBlock"],
    },
    "boost_counter": {
        "add_blocks": ["CsrBlock"],
        "csr_target_bias": "counter_csrs",
    },
    "explore_crossover": {
        "merge": True,
    },
}

_CATEGORIES = ["privilege", "float", "control", "memory", "counter", "misc"]


class FitnessCalculator:
    def evaluate(
        self,
        seed: str,
        category_deltas: dict[str, dict[str, int]],
        diff_families: list[str],
        exploration_value: float,
        lineage_depth: int = 0,
    ) -> SeedFitness:
        affinity: dict[str, float] = {}
        total_new = sum(d.get("new", 0) for d in category_deltas.values())
        if total_new > 0:
            for cat in _CATEGORIES:
                affinity[cat] = category_deltas.get(cat, {"new": 0}).get("new", 0) / total_new
        else:
            for cat in _CATEGORIES:
                affinity[cat] = 0.0

        return SeedFitness(
            seed=seed,
            category_affinity=affinity,
            novelty_score=float(total_new),
            diff_diversity=float(len(set(diff_families))),
            exploration_score=exploration_value,
            lineage_depth=lineage_depth,
        )

    def update_lineage(
        self,
        parent: SeedFitness,
        child_seed: str,
        child_bundle_data: dict,
    ) -> SeedFitness:
        child = self.evaluate(
            seed=child_seed,
            category_deltas=child_bundle_data.get("category_deltas", {}),
            diff_families=child_bundle_data.get("diff_families", []),
            exploration_value=child_bundle_data.get("exploration_value", 0.0),
            lineage_depth=parent.lineage_depth + 1,
        )
        alpha = 0.3
        for cat in _CATEGORIES:
            child.category_affinity[cat] = (
                alpha * child.category_affinity[cat]
                + (1.0 - alpha) * parent.category_affinity.get(cat, 0.0)
            )
        child.novelty_score = alpha * child.novelty_score + (1.0 - alpha) * parent.novelty_score
        child.diff_diversity = max(child.diff_diversity, parent.diff_diversity)
        child.exploration_score = (
            alpha * child.exploration_score + (1.0 - alpha) * parent.exploration_score
        )
        return child

    def dominant_category(self, category_deltas: dict[str, dict[str, int]]) -> str:
        """Return the category with the most new transitions."""
        best = "misc"
        best_new = -1
        for cat, d in category_deltas.items():
            if d.get("new", 0) > best_new:
                best_new = d["new"]
                best = cat
        return best
