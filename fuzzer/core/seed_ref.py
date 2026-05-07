from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


@dataclass
class SeedRef:
    """Lightweight queue element — stored in scheduler heaps."""
    seed_id: str              # "000042", corresponds to seeds/000042/seed_0.img
    queue: str                # "bug_proximity" | "stable_ancestor" | "exploration"
    score: float = 0.0        # priority score (heapq orders by this, descending)
    lineage_parent: str | None = None
    action: str = "generate"  # "generate" | "mutate"

    def __lt__(self, other: SeedRef) -> bool:
        return self.score > other.score  # heapq is min-heap; invert for max


@dataclass
class WorkerTask:
    """Complete context dispatched to a worker process.  All fields are picklable."""
    seed_ref: SeedRef
    output_dir: Path
    emu_cmd: str
    emu_path: str
    arch: Any                 # ArchConfig (picklable dataclass from generator)
    instr_number: int = 200
    template_type: str = "rocket"
    architecture: str = "rkt"
    dive_enable: bool = True
    is_rv32: bool = False
    allowed_ext_name: str = "base"
    bug_filter_arch: str = "xs"


@dataclass
class WorkerResult:
    """Observation data returned by a worker.  Picklable and lightweight."""
    seed_id: str
    img_path: str
    status: str
    exit_code: int
    duration_s: float
    failure_kind: str | None
    message: str
    transitions: list[dict[str, Any]]
    diff_families: list[str]
