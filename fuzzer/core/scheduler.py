from __future__ import annotations

import heapq
from collections import deque
from pathlib import Path
from typing import Any

from fuzzer.core.seed_ref import SeedRef


class MultiQueueScheduler:
    _QUEUE_ORDER = ("bug_proximity", "exploration", "stable_ancestor")
    _QUEUE_WEIGHTS = {"bug_proximity": 0.50, "stable_ancestor": 0.30, "exploration": 0.20}

    def __init__(self):
        self._queues: dict[str, Any] = {
            "bug_proximity": deque(),        # FIFO — bug candidates equal priority
            "exploration": [],               # heapq by score
            "stable_ancestor": [],           # heapq by score
        }
        self._seen_seeds: set[str] = set()

    def push(self, item: SeedRef) -> bool:
        seed_id = str(item.seed_id).strip()
        if not seed_id:
            return False
        if seed_id in self._seen_seeds:
            return False
        queue_name = item.queue if item.queue in self._queues else "exploration"
        ref = SeedRef(
            seed_id=seed_id, queue=queue_name, score=item.score,
            lineage_parent=item.lineage_parent, action=item.action,
        )
        if queue_name == "bug_proximity":
            self._queues[queue_name].append(ref)
        else:
            heapq.heappush(self._queues[queue_name], ref)
        self._seen_seeds.add(seed_id)
        return True

    def pop_next(self) -> SeedRef | None:
        for queue_name in self._QUEUE_ORDER:
            q = self._queues[queue_name]
            if not q:
                continue
            if queue_name == "bug_proximity":
                ref = q.popleft()
            else:
                ref = heapq.heappop(q)
            self._seen_seeds.discard(ref.seed_id)
            return ref
        return None

    def __len__(self) -> int:
        return sum(len(q) for q in self._queues.values())

    def pop_best(self, count: int) -> list[SeedRef]:
        """Pop up to `count` seeds with weighted distribution across queues."""
        result: list[SeedRef] = []
        remaining = count
        for queue_name in self._QUEUE_ORDER:
            if remaining <= 0:
                break
            quota = max(1, int(count * self._QUEUE_WEIGHTS.get(queue_name, 0.1)))
            quota = min(quota, remaining)
            taken = []
            for _ in range(min(quota, len(self._queues[queue_name]))):
                if queue_name == "bug_proximity":
                    ref = self._queues[queue_name].popleft()
                else:
                    ref = heapq.heappop(self._queues[queue_name])
                self._seen_seeds.discard(ref.seed_id)
                taken.append(ref)
            result.extend(taken)
            remaining = count - len(result)
        return result

    def dump_queue(self, path: Path) -> None:
        """Persist queue state to JSON file (atomic write via tmp + replace)."""
        import json

        payload = {}
        for name in self._QUEUE_ORDER:
            items = []
            for ref in self._queues[name]:
                items.append({
                    "seed_id": ref.seed_id,
                    "score": ref.score,
                    "lineage_parent": ref.lineage_parent,
                    "action": ref.action,
                })
            payload[name] = items
        tmp = path.with_suffix(".tmp")
        tmp.write_text(json.dumps(payload, ensure_ascii=False, indent=2))
        tmp.replace(path)

    def restore(self, path: Path) -> None:
        """Restore queue state from JSON file."""
        import json

        if not path.exists():
            return
        payload = json.loads(path.read_text(encoding="utf-8"))
        for name in self._QUEUE_ORDER:
            for item_data in payload.get(name, []):
                ref = SeedRef(
                    seed_id=item_data["seed_id"],
                    queue=name,
                    score=item_data.get("score", 0.0),
                    lineage_parent=item_data.get("lineage_parent"),
                    action=item_data.get("action", "generate"),
                )
                if name == "bug_proximity":
                    self._queues[name].append(ref)
                else:
                    heapq.heappush(self._queues[name], ref)
                self._seen_seeds.add(ref.seed_id)


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

    def pop_next(self) -> SeedRef | None:
        target_cat = min(
            self._category_saturation, key=lambda k: self._category_saturation[k]
        )
        if self._category_saturation.get(target_cat, 1.0) < 0.3:
            for queue_name in self._QUEUE_ORDER:
                q = self._queues[queue_name]
                if not q:
                    continue
                for i, item in enumerate(q):
                    seed_key = str(item.seed_id).strip()
                    if self._seed_category_tags.get(seed_key) == target_cat:
                        if queue_name == "bug_proximity":
                            del q[i]
                        else:
                            q[i] = q[-1]
                            q.pop()
                            if i < len(q):
                                heapq._siftup(q, i)
                                heapq._siftdown(q, 0, i)
                        self._seen_seeds.discard(seed_key)
                        return item
        return MultiQueueScheduler.pop_next(self)
