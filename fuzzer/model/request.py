from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class MutationRequest:
    case_id: str
    seed: str | None = None
    coverage_new_points: int = 0
    coverage_total_points: int = 0
    coverage_delta_ratio: float = 0.0
    coverage_points: list[str] = field(default_factory=list)
    observation_counts: dict[str, int] = field(default_factory=dict)
    first_failure_event: str | None = None
    seed_fitness: object = None
    target_category: str | None = None
    category_saturation: dict[str, float] = field(default_factory=dict)
