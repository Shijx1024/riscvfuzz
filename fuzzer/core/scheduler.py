from __future__ import annotations

from collections import deque
from dataclasses import dataclass


@dataclass
class ScheduledSeed:
    seed: str
    queue: str
    lineage_parent: str | None = None


class MultiQueueScheduler:
    _QUEUE_ORDER = ("bug_proximity", "exploration", "stable_ancestor")

    def __init__(self):
        self._queues: dict[str, deque[ScheduledSeed]] = {name: deque() for name in self._QUEUE_ORDER}
        self._seen_seeds: set[str] = set()

    def push(self, item: ScheduledSeed) -> bool:
        seed = str(item.seed).strip()
        if not seed:
            return False
        if seed in self._seen_seeds:
            return False
        queue_name = item.queue if item.queue in self._queues else "exploration"
        queued = ScheduledSeed(seed=seed, queue=queue_name, lineage_parent=item.lineage_parent)
        self._queues[queue_name].append(queued)
        self._seen_seeds.add(seed)
        return True

    def pop_next(self) -> ScheduledSeed | None:
        for queue_name in self._QUEUE_ORDER:
            queue = self._queues[queue_name]
            if queue:
                return queue.popleft()
        return None

    def __len__(self) -> int:
        return sum(len(queue) for queue in self._queues.values())


import math


class GoalDirectedScheduler(MultiQueueScheduler):
    """Multi-queue scheduler with category saturation-weighted priority boost.

    When a CSR category has low saturation (< 0.3), seeds tagged with that
    category get boosted ahead of standard queue order within the same
    priority level.
    """

    _SATURATION_DEFAULT: dict[str, float] = {
        "privilege": 0.0,
        "float": 0.0,
        "control": 0.0,
        "memory": 0.0,
        "counter": 0.0,
        "misc": 0.0,
    }

    def __init__(self):
        super().__init__()
        self._category_saturation: dict[str, float] = dict(self._SATURATION_DEFAULT)
        self._seed_category_tags: dict[str, str] = {}

    def tag_seed(self, seed: str, category: str) -> None:
        """Tag a seed with the CSR category it most triggers."""
        self._seed_category_tags[str(seed).strip()] = category

    def update_saturation(
        self,
        category_deltas: dict[str, dict[str, int]],
        transition_rarities: dict[str, float] | None = None,
    ) -> None:
        """Update per-category saturation from transition deltas and rarities."""
        rarity_map = transition_rarities or {}
        for cat in self._SATURATION_DEFAULT:
            delta = category_deltas.get(cat, {"new": 0, "total": 0})
            rarity = rarity_map.get(cat, 1.0)
            if delta["total"] > 0:
                novelty_rate = delta["new"] / float(delta["total"])
                self._category_saturation[cat] = min(
                    1.0,
                    max(0.0, 1.0 - (rarity * (0.5 + 0.5 * novelty_rate))),
                )

    def pop_next(self) -> ScheduledSeed | None:
        target_cat = min(
            self._category_saturation, key=lambda k: self._category_saturation[k]
        )
        if self._category_saturation.get(target_cat, 1.0) < 0.3:
            for queue_name in self._QUEUE_ORDER:
                queue = self._queues[queue_name]
                for i, item in enumerate(queue):
                    seed_key = str(item.seed).strip()
                    if self._seed_category_tags.get(seed_key) == target_cat:
                        del queue[i]
                        self._seen_seeds.discard(seed_key)
                        return item
        return super().pop_next()
