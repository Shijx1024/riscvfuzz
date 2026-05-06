from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


@dataclass
class ExecuteResult:
    case_id: str = ""
    status: str = ""
    exit_code: int | None = None
    command: list[str] = field(default_factory=list)
    reference_name: str = ""
    duration_s: float = 0.0
    failure_kind: str | None = None
    message: str = ""
    observation_path: Path | None = None
    observation_counts: dict[str, int] = field(default_factory=dict)
    observation_coverage_points: list[str] = field(default_factory=list)
    first_failure_event: str | None = None
    observation_total_events: int = 0
    observation_max_cycle: int | None = None
    observation_max_instr: int | None = None
    observation_unique_pc_pages: int = 0
    csr_transitions: list[dict[str, Any]] = field(default_factory=list)
    diff_families: list[str] = field(default_factory=list)
    sync_decisions: list[dict[str, str]] = field(default_factory=list)
    syncable_count: int = 0
    potential_bug_count: int = 0


@dataclass
class MutationResult:
    case_id: str
    status: str = ""
    next_seed: str | None = None
    message: str = ""
