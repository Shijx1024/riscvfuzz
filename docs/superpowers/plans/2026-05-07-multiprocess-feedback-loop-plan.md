# Multi-Process Feedback Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the single-process `_run_dut_tests_with_feedback()` with a Manager-Worker batch loop using ProcessPoolExecutor, while activating dead code (FitnessCalculator, transition_rarities) and fixing coverage persistence.

**Architecture:** Main process owns corpus/scheduler/decision. Worker pool (M = `dut_config.threads`) runs gen/mutate → execute → observe → return raw data. Each batch: snapshot corpus → dispatch M tasks → score against snapshot → update global corpus → re-enqueue seeds → persist.

**Tech Stack:** Python 3.10+, `concurrent.futures.ProcessPoolExecutor`, `dataclasses`, `heapq`, `pathlib`

---

### Task 1: Create SeedRef, WorkerTask, WorkerResult dataclasses

**Files:**
- Create: `fuzzer/core/seed_ref.py`
- (No test yet — pure data, tested implicitly by later tasks)

- [ ] **Step 1: Create `fuzzer/core/seed_ref.py`**

Write the complete module:

```python
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
```

- [ ] **Step 2: Verify imports**

```bash
PYTHONPATH=. python -c "from fuzzer.core.seed_ref import SeedRef, WorkerTask, WorkerResult; r = SeedRef('000001', 'exploration'); print(r)"
```
Expected: `SeedRef(seed_id='000001', queue='exploration', score=0.0, lineage_parent=None, action='generate')`

- [ ] **Step 3: Commit**

```bash
git add fuzzer/core/seed_ref.py
git commit -m "feat: add SeedRef, WorkerTask, WorkerResult dataclasses"
```

---

### Task 2: Refactor scheduler to SeedRef, heapq, pop_best, dump/restore

**Files:**
- Modify: `fuzzer/core/scheduler.py`
- Test: `fuzzer/tests/test_feedback_loop.py` (adapt existing + add new)

- [ ] **Step 1: Adapt existing tests for ScheduledSeed → SeedRef**

In `fuzzer/tests/test_feedback_loop.py`, update the `TestScheduler` imports and all `ScheduledSeed` usages to `SeedRef`. The class attribute `.seed` becomes `.seed_id`.

Find all occurrences:
```
ScheduledSeed(seed="...", queue="...")
```
Replace with:
```
SeedRef(seed_id="...", queue="...")
```

In assertions, change `.seed` to `.seed_id`:
```python
# Before
assert popped.seed == "s1"
# After
assert popped.seed_id == "s1"
```

- [ ] **Step 2: Run existing scheduler tests to verify compatibility**

```bash
PYTHONPATH=. python -m pytest fuzzer/tests/test_feedback_loop.py::TestScheduler -v
```
Expected: 4 tests PASS

- [ ] **Step 3: Refactor scheduler internals — deque → heapq for exploration/stable_ancestor**

Read `fuzzer/core/scheduler.py`. Currently all three queues are `deque`. Change `stable_ancestor` and `exploration` to use `list` (heapq). `bug_proximity` stays FIFO deque.

Modify `MultiQueueScheduler.__init__`:
```python
def __init__(self):
    self._queues: dict[str, Any] = {
        "bug_proximity": deque(),        # FIFO — bug candidates equal priority
        "exploration": [],               # heapq by score
        "stable_ancestor": [],           # heapq by score
    }
    self._seen_seeds: set[str] = set()
```

Modify `push()` to push into the appropriate structure:
```python
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
        self._queues[queue_name].append(ref)          # FIFO
    else:
        heapq.heappush(self._queues[queue_name], ref)  # heapq (min-heap, score inverted via __lt__)
    self._seen_seeds.add(seed_id)
    return True
```

Add `import heapq` at top of file.

- [ ] **Step 4: Add pop_best() method**

Add to `MultiQueueScheduler`:
```python
_QUEUE_WEIGHTS = {"bug_proximity": 0.50, "stable_ancestor": 0.30, "exploration": 0.20}

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
        # Redistribute unused quota to remaining queues
    return result
```

Update `pop_next()` to handle heapq queues:
```python
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
```

Update `__len__`:
```python
def __len__(self) -> int:
    return sum(len(q) for q in self._queues.values())
```

- [ ] **Step 5: Adapt GoalDirectedScheduler**

The `pop_next()` override in `GoalDirectedScheduler` iterates the deque. Update to handle heapq queues:

```python
def pop_next(self) -> SeedRef | None:
    target_cat = min(self._category_saturation, key=lambda k: self._category_saturation[k])
    if self._category_saturation.get(target_cat, 1.0) < 0.3:
        for queue_name in self._QUEUE_ORDER:
            q = self._queues[queue_name]
            if not q:
                continue
            # Scan for tagged seed matching target category
            for i, item in enumerate(q):
                seed_key = str(item.seed_id).strip()
                if self._seed_category_tags.get(seed_key) == target_cat:
                    if queue_name == "bug_proximity":
                        del q[i]
                    else:
                        # heapq delete: remove at index, re-heapify
                        q[i] = q[-1]
                        q.pop()
                        if i < len(q):
                            heapq._siftup(q, i)
                            heapq._siftdown(q, 0, i)
                    self._seen_seeds.discard(seed_key)
                    return item
    return MultiQueueScheduler.pop_next(self)
```

- [ ] **Step 6: Add dump_queue() and restore() to scheduler**

```python
def dump_queue(self, path: Path) -> None:
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
    import json
    if not path.exists():
        return
    payload = json.loads(path.read_text())
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
```

- [ ] **Step 7: Write new tests for pop_best and dump/restore**

In `fuzzer/tests/test_feedback_loop.py`, add to `TestScheduler`:

```python
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
```

- [ ] **Step 8: Run all scheduler tests**

```bash
PYTHONPATH=. python -m pytest fuzzer/tests/test_feedback_loop.py::TestScheduler -v
```
Expected: 7 tests PASS

- [ ] **Step 9: Commit**

```bash
git add fuzzer/core/scheduler.py fuzzer/tests/test_feedback_loop.py
git commit -m "refactor: scheduler to SeedRef with heapq, pop_best, dump/restore"
```

---

### Task 3: Add snapshot, preview_delta_from_snapshot, get_category_rarities to RunCorpus

**Files:**
- Modify: `fuzzer/core/corpus.py`
- Test: `fuzzer/tests/test_feedback_loop.py` (extend TestRunCorpus)

- [ ] **Step 1: Add snapshot() method**

In `RunCorpus` class, add after `preview_coverage_delta`:

```python
def snapshot(self) -> set[str]:
    """Return a frozen copy of currently-seen coverage points for isolated scoring."""
    return set(self._seen_coverage_points)
```

- [ ] **Step 2: Add preview_delta_from_snapshot() method**

```python
def preview_delta_from_snapshot(
    self, snapshot: set[str], transitions: list[dict[str, Any]]
) -> dict[str, Any]:
    """Compute coverage delta of transitions against a frozen snapshot.

    Uses make_coverage_key() (coarse keys: {category}|{mnemonic}) rather
    than _serialize_transition (fine keys with register values).
    """
    from core.observation import make_coverage_key

    cov_keys: set[str] = set()
    by_category: dict[str, dict[str, int]] = {}
    for t in transitions:
        key = make_coverage_key(t)
        cov_keys.add(key)
        cat = t.get("category", "misc")
        bucket = by_category.setdefault(cat, {"new": 0, "total": 0})
        bucket["total"] += 1
        if key not in snapshot:
            bucket["new"] += 1
    new_keys = cov_keys - snapshot
    total = len(cov_keys)
    new_count = len(new_keys)
    return {
        "new_coverage": new_count,
        "total_coverage": total,
        "by_category": by_category,
    }
```

- [ ] **Step 3: Add get_category_rarities() method**

```python
def get_category_rarities(self) -> dict[str, float]:
    """Average transition rarity per CSR category."""
    import math
    from collections import defaultdict
    cat_sums: dict[str, float] = defaultdict(float)
    cat_counts: dict[str, int] = defaultdict(int)
    for key, freq in self._transition_frequency.items():
        cat = key.split("|")[0] if "|" in key else "misc"
        rarity = 1.0 / (1.0 + math.log2(1.0 + float(freq)))
        cat_sums[cat] += rarity
        cat_counts[cat] += 1
    return {cat: cat_sums[cat] / max(cat_counts[cat], 1) for cat in cat_sums}
```

- [ ] **Step 4: Add transition_keys_full to dump_campaign_state()**

In `dump_campaign_state()`, add after the frequency sample:

```python
payload["transition_keys"] = sorted(self._seen_transitions)
```

- [ ] **Step 5: Update bootstrap_from_campaign_state() for full transition restore**

In `bootstrap_from_campaign_state()`, add:

```python
transition_keys_full = payload.get("transition_keys_full", [])
if isinstance(transition_keys_full, list):
    for key in transition_keys_full:
        if isinstance(key, str) and key.strip():
            self._seen_transitions.add(key.strip())
            cat = key.split("|")[0] if "|" in key else "misc"
            cat_set = self._seen_transitions_by_category.setdefault(cat, set())
            cat_set.add(key.strip())
```

- [ ] **Step 6: Write tests**

In `TestRunCorpus`:

```python
def test_snapshot_returns_copy(self):
    corpus = RunCorpus()
    corpus._seen_coverage_points.add("privilege|csrrs")
    snap = corpus.snapshot()
    assert "privilege|csrrs" in snap
    corpus._seen_coverage_points.add("float|fadd.s")
    assert "float|fadd.s" not in snap  # snapshot is frozen

def test_preview_delta_from_snapshot(self):
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
    corpus = RunCorpus()
    corpus._transition_frequency = {
        "privilege|v1|v2|csrrs:0x342": 1,
        "privilege|v3|v4|csrrw:0x123": 8,
        "float|v5|v6|fadd.s:0x53": 1,
    }
    rarities = corpus.get_category_rarities()
    assert "privilege" in rarities
    assert "float" in rarities
    # privilege category: two keys, freq 1 (rarity=0.63) and freq 8 (rarity=0.24), avg ~0.44
    assert 0.3 < rarities["privilege"] < 0.6
```

- [ ] **Step 7: Run tests**

```bash
PYTHONPATH=. python -m pytest fuzzer/tests/test_feedback_loop.py::TestRunCorpus -v
```
Expected: 6 tests PASS (3 existing + 3 new)

- [ ] **Step 8: Commit**

```bash
git add fuzzer/core/corpus.py fuzzer/tests/test_feedback_loop.py
git commit -m "feat: add snapshot, preview_delta_from_snapshot, get_category_rarities to RunCorpus"
```

---

### Task 4: Harden FeedbackSignalExtractor.extract()

**Files:**
- Modify: `fuzzer/core/feedback_loop.py`

- [ ] **Step 1: Apply .get() guards**

Find the two locations in `extract()` where `delta["total"]` and `delta["new"]` are accessed directly:

```python
# Before (line 54-57):
if delta["total"] > 0:
    rarity = (transition_rarities or {}).get(cat, 1.0)
    exploration_value += (
        weight * rarity * (delta["new"] / float(delta["total"]))
    )

# After:
if delta.get("total", 0) > 0:
    rarity = (transition_rarities or {}).get(cat, 1.0)
    exploration_value += (
        weight * rarity * (delta.get("new", 0) / float(delta["total"]))
    )
```

- [ ] **Step 2: Run existing tests**

```bash
PYTHONPATH=. python -m pytest fuzzer/tests/test_feedback_loop.py::TestFeedbackSignals -v
```
Expected: 3 tests PASS

- [ ] **Step 3: Commit**

```bash
git add fuzzer/core/feedback_loop.py
git commit -m "fix: harden extract() with .get() guards against KeyError"
```

---

### Task 5: Activate FitnessCalculator

**Files:**
- Modify: `fuzzer/core/fitness.py`
- (Tests added in Task 10)

- [ ] **Step 1: Read current fitness.py to confirm evaluate() signature**

Read: `fuzzer/core/fitness.py`

The `FitnessCalculator.evaluate()` takes:
- `category_deltas: dict[str, dict[str, int]]` — {"privilege": {"new": 2, "total": 3}, ...}
- `diff_families: list[str]` — ["fp_rounding", "csr_write", ...]
- `exploration_score: float` — from FeedbackSignalExtractor
- `lineage_parent: SeedFitness | None` — parent seed fitness

It returns `SeedFitness`.

- [ ] **Step 2: Ensure evaluate() handles empty inputs**

Check that the method handles:
- Empty `category_deltas` (all zeros) → affinities all 0.0
- Empty `diff_families` → diff_diversity = 0
- `lineage_parent=None` → lineage_depth = 0

If not already handled, add guards. Read the file and verify.

- [ ] **Step 3: Add category_affinity extraction helper**

If `evaluate()` doesn't already extract the dominant category, add:

```python
def dominant_category(self, category_deltas: dict[str, dict[str, int]]) -> str:
    """Return the category with the most new transitions."""
    best = "misc"
    best_new = -1
    for cat, d in category_deltas.items():
        if d.get("new", 0) > best_new:
            best_new = d["new"]
            best = cat
    return best
```

This supports `GoalDirectedScheduler.tag_seed()`, which marks seeds by their dominant CSR category.

- [ ] **Step 4: Commit**

```bash
git add fuzzer/core/fitness.py
git commit -m "feat: activate FitnessCalculator with dominant_category helper"
```

---

### Task 6: Add load_json to serde.py

**Files:**
- Modify: `fuzzer/utils/serde.py`

- [ ] **Step 1: Add load_json()**

```python
def load_json(path: Path) -> Any:
    """Load and parse a JSON file.  Returns parsed Python object."""
    return json.loads(path.read_text(encoding="utf-8"))
```

Add `import json` if not already present.

- [ ] **Step 2: Verify**

```bash
PYTHONPATH=. python -c "
from pathlib import Path
from fuzzer.utils.serde import dump_json, load_json
import tempfile, os
d = tmp_path = Path(tempfile.mkdtemp()) / 'test.json'
dump_json({'a': 1}, d)
assert load_json(d) == {'a': 1}
print('OK')
"
```

- [ ] **Step 3: Commit**

```bash
git add fuzzer/utils/serde.py
git commit -m "feat: add load_json() to serde for deserialization"
```

---

### Task 7: Create worker.py — worker_entry, _setup_worker_singletons, worker_generate, worker_mutate, worker_execute

**Files:**
- Create: `fuzzer/executor/worker.py`

- [ ] **Step 1: Write _setup_worker_singletons() and seed_path()**

```python
from __future__ import annotations

import os
import subprocess
import time
from pathlib import Path
from typing import Any

from core.observation import parse_observation
from core.seed_ref import WorkerTask, WorkerResult
from core.status import CaseStatus, FailureKind


def seed_path(output_dir: Path, seed_id: str) -> Path:
    """Convention: {output_dir}/{seed_id}/seed_0.img"""
    return output_dir / seed_id / "seed_0.img"


def _setup_worker_singletons(allowed_ext_name: str, architecture: str) -> None:
    """Initialize generator module-level singletons inside a worker process.

    These are set by setup_config() in the main process and inherited via
    fork on Linux.  This function ensures compatibility with spawn mode.
    """
    from generator.asm_template_manager.ext_list import allowed_ext
    from generator.bug_filter import bug_filter
    allowed_ext.setup_ext(allowed_ext_name)
    bug_filter.set_architecture(architecture)
```

- [ ] **Step 2: Write worker_generate()**

```python
def worker_generate(
    *, seed_id: str, output_dir: Path, arch: Any,
    instr_number: int, template_type: str, architecture: str,
    dive_enable: bool, is_rv32: bool,
) -> Path:
    """Generate a single seed program.  Returns path to seed_0.img."""
    from generator.core.generator import generate_instructions_parallel
    from generator.core.generator.generate_instructions import create_template_instance
    from utils.elf_to_img import process_file

    gen_dir = output_dir / seed_id
    gen_dir.mkdir(parents=True, exist_ok=True)

    generate_instructions_parallel(
        instr_number=instr_number,
        seed_times=1,
        eliminate_enable=dive_enable,
        is_rv32=is_rv32,
        max_workers=1,
        arch=arch,
        template_type=template_type,
        out_dir=str(gen_dir),
        architecture=architecture,
    )

    # Direct process_file call — avoids nested ThreadPoolExecutor in
    # process_assembly_files() since seed_times=1
    asm_files = list(gen_dir.glob("*.S"))
    if not asm_files:
        raise RuntimeError(f"No .S file generated in {gen_dir}")
    img_dir = gen_dir / "img_file"
    elf_dir = gen_dir / "elf_file"
    img_dir.mkdir(parents=True, exist_ok=True)
    elf_dir.mkdir(parents=True, exist_ok=True)
    process_file(str(asm_files[0].name), str(gen_dir), str(img_dir), str(elf_dir))

    return img_dir / "seed_0.img"
```

- [ ] **Step 3: Write worker_mutate()**

```python
def worker_mutate(
    *, seed_id: str, parent_img: Path, output_dir: Path, arch: Any,
    dive_enable: bool, is_rv32: bool, template_type: str, architecture: str,
) -> Path:
    """Mutate an existing seed.  Returns path to new seed_0.img."""
    import shutil
    from generator.core.mutator import mutate_instructions_parallel
    from utils.elf_to_img import process_file

    # Locate parent .S file
    parent_dir = parent_img.parent.parent  # seeds/000042/ → parent of img_file/
    asm_files = list(parent_dir.glob("*.S"))
    if not asm_files:
        raise RuntimeError(f"No .S file for parent seed {parent_img}")
    parent_asm = asm_files[0]

    gen_dir = output_dir / seed_id
    gen_dir.mkdir(parents=True, exist_ok=True)
    mutate_input = gen_dir / "input"
    mutate_output = gen_dir / "output"
    mutate_input.mkdir(parents=True, exist_ok=True)
    mutate_output.mkdir(parents=True, exist_ok=True)

    shutil.copy2(str(parent_asm), str(mutate_input / parent_asm.name))

    mutate_instructions_parallel(
        directory_path=mutate_input,
        mutate_directory=mutate_output,
        max_workers=1,
        enable_ext=False,
        exclude_extensions=[],
        eliminate_enable=dive_enable,
        arch=arch,
        template_type=template_type,
    )

    asm_outputs = list(mutate_output.glob("*.S"))
    if not asm_outputs:
        raise RuntimeError(f"No mutated .S file in {mutate_output}")
    img_dir = gen_dir / "img_file"
    elf_dir = gen_dir / "elf_file"
    img_dir.mkdir(parents=True, exist_ok=True)
    elf_dir.mkdir(parents=True, exist_ok=True)
    process_file(str(asm_outputs[0].name), str(mutate_output), str(img_dir), str(elf_dir))

    return img_dir / "seed_0.img"
```

- [ ] **Step 4: Write worker_execute()**

```python
def worker_execute(
    *, img_path: Path, seed_id: str, emu_cmd: str, emu_path: str,
) -> dict[str, Any]:
    """Run the emulator on a seed and return execution result dict.

    Returns dict with keys: status, exit_code, duration_s, failure_kind,
    message, observation_path.
    """
    observe_rel = f"difftest.observe.{seed_id}.jsonl"
    observe_flag = f" --rvfuzz-observe={observe_rel} --rvfuzz-observe-level=all"

    command = emu_cmd.replace("$1", f'"{img_path}"')
    if "--rvfuzz-observe=" not in command:
        command = command + observe_flag

    start = time.monotonic()
    try:
        proc = subprocess.run(
            command, shell=True, cwd=emu_path, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=300,
        )
        duration = time.monotonic() - start
        if proc.returncode == 0:
            status = CaseStatus.EXECUTED.value
            failure_kind = None
        else:
            status = CaseStatus.DIFF_FAILED.value
            failure_kind = FailureKind.DIFF_MISMATCH.value
        return {
            "status": status,
            "exit_code": proc.returncode,
            "duration_s": duration,
            "failure_kind": failure_kind,
            "message": proc.stdout[-500:] if proc.stdout else "",
            "observation_path": Path(emu_path) / observe_rel,
        }
    except subprocess.TimeoutExpired:
        return {
            "status": CaseStatus.TIMEOUT.value,
            "exit_code": -1,
            "duration_s": time.monotonic() - start,
            "failure_kind": FailureKind.TIMEOUT.value,
            "message": "Timeout after 300s",
            "observation_path": None,
        }
    except Exception as exc:
        return {
            "status": CaseStatus.INFRA_ERROR.value,
            "exit_code": -1,
            "duration_s": time.monotonic() - start,
            "failure_kind": FailureKind.INFRA_ERROR.value,
            "message": str(exc),
            "observation_path": None,
        }
```

- [ ] **Step 5: Write worker_entry() — the ProcessPoolExecutor target**

```python
def worker_entry(task: WorkerTask) -> WorkerResult:
    """Entry point for ProcessPoolExecutor.  Stateless — all config in task."""
    _setup_worker_singletons(task.allowed_ext_name, task.bug_filter_arch)

    # 1. Generate or mutate
    if task.seed_ref.action == "generate":
        img_path = worker_generate(
            seed_id=task.seed_ref.seed_id,
            output_dir=task.output_dir,
            arch=task.arch,
            instr_number=task.instr_number,
            template_type=task.template_type,
            architecture=task.architecture,
            dive_enable=task.dive_enable,
            is_rv32=task.is_rv32,
        )
    else:
        parent_img = seed_path(task.output_dir, task.seed_ref.lineage_parent or task.seed_ref.seed_id)
        img_path = worker_mutate(
            seed_id=task.seed_ref.seed_id,
            parent_img=parent_img,
            output_dir=task.output_dir,
            arch=task.arch,
            dive_enable=task.dive_enable,
            is_rv32=task.is_rv32,
            template_type=task.template_type,
            architecture=task.architecture,
        )

    # 2. Execute
    exec_data = worker_execute(
        img_path=img_path, seed_id=task.seed_ref.seed_id,
        emu_cmd=task.emu_cmd, emu_path=task.emu_path,
    )

    # 3. Parse observation
    obs_path = exec_data["observation_path"]
    if obs_path is not None and obs_path.exists():
        obs = parse_observation(obs_path)
        # Clean up — data already extracted
        try:
            obs_path.unlink()
        except OSError:
            pass
    else:
        obs = type("_Obs", (), {"transitions": [], "diff_families": []})()

    return WorkerResult(
        seed_id=task.seed_ref.seed_id,
        img_path=str(img_path),
        status=exec_data["status"],
        exit_code=exec_data["exit_code"],
        duration_s=exec_data["duration_s"],
        failure_kind=exec_data["failure_kind"],
        message=exec_data["message"],
        transitions=obs.transitions,
        diff_families=obs.diff_families,
    )
```

- [ ] **Step 6: Verify the module imports**

```bash
PYTHONPATH=. python -c "from fuzzer.executor.worker import worker_entry, worker_generate, worker_mutate, worker_execute; print('imports OK')"
```

- [ ] **Step 7: Commit**

```bash
git add fuzzer/executor/worker.py
git commit -m "feat: add stateless worker_entry, worker_generate, worker_mutate, worker_execute"
```

---

### Task 8: Replace _run_dut_tests_with_feedback with Manager-Worker loop

**Files:**
- Modify: `fuzzer/executor/dut_executor.py`
- (Tests run at Task 10)

- [ ] **Step 1: Add build_bundle() and allocate_seed_id() helpers**

At module level in `dut_executor.py`, add after the existing imports:

```python
from core.seed_ref import SeedRef, WorkerTask, WorkerResult
from core.status import CaseStatus, FailureKind


def _build_bundle(seed_ref: SeedRef, result: WorkerResult,
                  execute_result: Any) -> dict[str, Any]:
    """Build a corpus-compatible bundle dict from typed worker data."""
    from core.observation import make_coverage_key
    points = {make_coverage_key(t) for t in result.transitions}
    return {
        "case_id": result.seed_id,
        "seed": seed_ref.seed_id,
        "lineage_parent": seed_ref.lineage_parent,
        "status": result.status,
        "coverage_result": {"points": points, "status": "collected"},
        "execute_result": execute_result,
        "feedback_decision": None,
    }


def _allocate_seed_id(corpus: Any) -> str:
    """Allocate next sequential seed_id.  Coroutine-friendly via corpus tracking."""
    next_id = getattr(corpus, '_next_seed_id', 0) + 1
    corpus._next_seed_id = next_id
    return f"{next_id:06d}"
```

- [ ] **Step 2: Write the new _run_dut_tests_with_feedback()**

Replace the entire function body. The new function:

```python
def _run_dut_tests_with_feedback(config: Config, config_filename: str,
                                 feedback: dict) -> list[TestResult]:
    """Manager-Worker batch fuzzing loop (RVFUZZ multiprocess implant)."""
    from concurrent.futures import ProcessPoolExecutor, as_completed
    from core.observation import make_coverage_key
    from core.sync import SyncDecisionEngine
    from core.seed_ref import SeedRef, WorkerTask, WorkerResult
    from core.status import CaseStatus
    from core.fitness import FitnessCalculator
    from model.result import ExecuteResult
    from executor.worker import worker_entry

    corpus = feedback["corpus"]
    scheduler = feedback["scheduler"]
    signal_extractor = feedback["signal_extractor"]
    decision_policy = feedback["decision_policy"]
    sync_engine = SyncDecisionEngine()
    fitness_calc = FitnessCalculator()

    M = max(1, config.dut_target.threads)
    output_dir = Path(config.corpus_dir) / "seeds" if config.corpus_dir else Path("outputs") / "seeds"
    output_dir.mkdir(parents=True, exist_ok=True)

    # Extract arch + seed params from first seed config
    seed_config = config.seeds[0]
    if not isinstance(seed_config, GeneratedSeedConfig):
        logger.error("Feedback loop requires a GeneratedSeedConfig")
        return []

    setup_divefuzz(seed_config, global_logger=logger)
    from executor.divefuzz_adapter import _divefuzz_config
    arch = _divefuzz_config.arch
    allowed_ext_name = _divefuzz_config.allowed_ext_name
    instr_number = seed_config.divefuzz.ins_num
    template_type = seed_config.divefuzz.template_type
    architecture = seed_config.divefuzz.architecture
    dive_enable = seed_config.divefuzz.dive_enable
    is_rv32 = seed_config.divefuzz.is_rv32

    # Warmup
    if len(scheduler) == 0:
        logger.info("[RVFUZZ] Scheduler empty — warmup generating %d seeds", M)
        warmup_tasks = []
        for _ in range(M):
            sid = _allocate_seed_id(corpus)
            ref = SeedRef(sid, "exploration", score=0.5, action="generate")
            scheduler.push(ref)
        warmup_batch = scheduler.pop_best(M)
        warmup_tasks = [
            WorkerTask(ref, output_dir=output_dir,
                       emu_cmd=config.dut_target.cmd,
                       emu_path=config.dut_target.emu_path,
                       arch=arch, instr_number=instr_number,
                       template_type=template_type, architecture=architecture,
                       dive_enable=dive_enable, is_rv32=is_rv32,
                       allowed_ext_name=allowed_ext_name,
                       bug_filter_arch=architecture)
            for ref in warmup_batch
        ]
        with ProcessPoolExecutor(max_workers=M) as pool:
            futures = {pool.submit(worker_entry, t): t for t in warmup_tasks}
            warmup_results = []
            for fut in as_completed(futures):
                warmup_results.append(fut.result())
        # Score warmup results against empty snapshot
        snapshot = corpus.snapshot()
        for task, result in zip(warmup_tasks, warmup_results):
            delta = corpus.preview_delta_from_snapshot(snapshot, result.transitions)
            sync_summary = sync_engine.summary(
                sync_engine.classify([{"family": f, "cov": ""} for f in result.diff_families])
            )
            diff_delta = corpus.preview_diff_delta(result.diff_families)
            diff_novelty = len(diff_delta["new_families"]) / max(len(set(result.diff_families)), 1) \
                           if result.diff_families else 0.0
            signals = signal_extractor.extract(
                status=result.status, failure_kind=result.failure_kind,
                coverage_new_points=delta["new_coverage"],
                coverage_total_points=delta["total_coverage"],
                category_deltas=delta["by_category"],
                transition_rarities=corpus.get_category_rarities(),
                diff_novelty_score=diff_novelty,
                syncable_count=sync_summary["syncable_count"],
            )
            parent_fitness = corpus.get_seed_fitness(task.seed_ref.lineage_parent or "")
            fitness = fitness_calc.evaluate(
                category_deltas=delta["by_category"],
                diff_families=result.diff_families,
                exploration_score=signals.exploration_value,
                lineage_parent=parent_fitness,
            )
            corpus.update_seed_fitness(result.seed_id, fitness)
            # Mark seed category for GoalDirectedScheduler
            dom_cat = fitness_calc.dominant_category(delta["by_category"])
            scheduler.tag_seed(result.seed_id, dom_cat)

            corpus.record_transitions(result.transitions)
            if result.diff_families:
                corpus.record_diff_families(result.diff_families, result.seed_id)

            exec_result = ExecuteResult(
                case_id=result.seed_id, status=result.status,
                csr_transitions=result.transitions,
                diff_families=result.diff_families,
                syncable_count=sync_summary["syncable_count"],
                potential_bug_count=sync_summary["potential_bug_count"],
            )
            bundle = _build_bundle(task.seed_ref, result, exec_result)
            decision = decision_policy.decide(signals)
            bundle["feedback_decision"] = decision.decision
            corpus.record(bundle)

            if decision.decision == "promote_mutation":
                scheduler.push(SeedRef(result.seed_id, decision.queue,
                                       fitness.exploration_score,
                                       lineage_parent=result.seed_id,
                                       action=task.seed_ref.action))
            elif decision.decision == "keep_in_corpus":
                scheduler.push(SeedRef(result.seed_id, "exploration",
                                       fitness.exploration_score,
                                       lineage_parent=result.seed_id,
                                       action=task.seed_ref.action))

    # --- Main loop ---
    total_iter = 0
    while total_iter < config.batch_size and len(scheduler) > 0:
        # 5a. Snapshot
        snapshot = corpus.snapshot()

        # 5b. Pop batch
        if len(scheduler) < M:
            needed = M - len(scheduler)
            for _ in range(needed):
                sid = _allocate_seed_id(corpus)
                scheduler.push(SeedRef(sid, "exploration", score=0.5, action="generate"))
        batch = scheduler.pop_best(M)
        logger.info("[RVFUZZ] Batch %d: dispatching %d seeds", total_iter, len(batch))

        # 5c. Dispatch
        tasks = [
            WorkerTask(ref, output_dir=output_dir,
                       emu_cmd=config.dut_target.cmd,
                       emu_path=config.dut_target.emu_path,
                       arch=arch, instr_number=instr_number,
                       template_type=template_type, architecture=architecture,
                       dive_enable=dive_enable, is_rv32=is_rv32,
                       allowed_ext_name=allowed_ext_name,
                       bug_filter_arch=architecture)
            for ref in batch
        ]
        with ProcessPoolExecutor(max_workers=M) as pool:
            futures = {pool.submit(worker_entry, t): t for t in tasks}
            results = []
            for fut in as_completed(futures):
                try:
                    results.append(fut.result())
                except Exception as exc:
                    task = futures[fut]
                    logger.error("[RVFUZZ] Worker failed for seed %s: %s",
                                 task.seed_ref.seed_id, exc)
                    # Re-enqueue as exploration
                    scheduler.push(SeedRef(task.seed_ref.seed_id, "exploration",
                                           0.1, action=task.seed_ref.action))

        # Sort results back to task order for zip
        result_map = {r.seed_id: r for r in results}
        ordered_results = [result_map[t.seed_ref.seed_id] for t in tasks
                           if t.seed_ref.seed_id in result_map]
        ordered_tasks = [t for t in tasks if t.seed_ref.seed_id in result_map]

        # 5d. First pass: score against snapshot + store decisions
        scores: dict[str, float] = {}
        decisions: dict[str, Any] = {}
        for task, result in zip(ordered_tasks, ordered_results):
            delta = corpus.preview_delta_from_snapshot(snapshot, result.transitions)
            sync_summary = sync_engine.summary(
                sync_engine.classify([{"family": f, "cov": ""} for f in result.diff_families])
            )
            diff_delta = corpus.preview_diff_delta(result.diff_families)
            diff_novelty = len(diff_delta["new_families"]) / max(len(set(result.diff_families)), 1) \
                           if result.diff_families else 0.0
            signals = signal_extractor.extract(
                status=result.status, failure_kind=result.failure_kind,
                coverage_new_points=delta["new_coverage"],
                coverage_total_points=delta["total_coverage"],
                category_deltas=delta["by_category"],
                transition_rarities=corpus.get_category_rarities(),
                diff_novelty_score=diff_novelty,
                syncable_count=sync_summary["syncable_count"],
            )
            parent_fitness = corpus.get_seed_fitness(task.seed_ref.lineage_parent or "")
            fitness = fitness_calc.evaluate(
                category_deltas=delta["by_category"],
                diff_families=result.diff_families,
                exploration_score=signals.exploration_value,
                lineage_parent=parent_fitness,
            )
            corpus.update_seed_fitness(result.seed_id, fitness)
            dom_cat = fitness_calc.dominant_category(delta["by_category"])
            scheduler.tag_seed(result.seed_id, dom_cat)
            scheduler.update_saturation(delta["by_category"])
            scores[result.seed_id] = fitness.exploration_score
            decisions[result.seed_id] = decision_policy.decide(signals)

        # 5e. Second pass: update global corpus
        for task, result in zip(ordered_tasks, ordered_results):
            corpus.record_transitions(result.transitions)
            if result.diff_families:
                corpus.record_diff_families(result.diff_families, result.seed_id)
            sync_summary = sync_engine.summary(
                sync_engine.classify([{"family": f, "cov": ""} for f in result.diff_families])
            )
            exec_result = ExecuteResult(
                case_id=result.seed_id, status=result.status,
                csr_transitions=result.transitions,
                diff_families=result.diff_families,
                syncable_count=sync_summary["syncable_count"],
                potential_bug_count=sync_summary["potential_bug_count"],
            )
            bundle = _build_bundle(task.seed_ref, result, exec_result)
            bundle["feedback_decision"] = decisions[result.seed_id].decision
            corpus.record(bundle)

        # 5f. Third pass: re-enqueue based on decisions
        for task, result in zip(ordered_tasks, ordered_results):
            score = scores[result.seed_id]
            decision = decisions[result.seed_id]
            if decision.decision == "promote_mutation":
                scheduler.push(SeedRef(result.seed_id, decision.queue, score,
                                       lineage_parent=result.seed_id,
                                       action=task.seed_ref.action))
                # Enqueue mutation for next batch
                mutated_id = _allocate_seed_id(corpus)
                scheduler.push(SeedRef(mutated_id, "stable_ancestor", score,
                                       lineage_parent=result.seed_id,
                                       action="mutate"))
            elif decision.decision == "keep_in_corpus":
                scheduler.push(SeedRef(result.seed_id, "exploration", score,
                                       lineage_parent=result.seed_id,
                                       action=task.seed_ref.action))
            # archive_only / discard → not re-enqueued

        # 5g. Persist
        corpus.dump_campaign_state(output_dir.parent / "campaign_state.json")
        scheduler.dump_queue(output_dir.parent / "queue_state.json")
        total_iter += 1

    logger.info("[RVFUZZ] Feedback loop complete. Iterations: %d", total_iter)
    return []  # TestResult list — aggregated separately
```

- [ ] **Step 2: Keep _run_dut_tests_original() unchanged**

Verify the original path still works (it doesn't use feedback dict, so it's untouched).

- [ ] **Step 3: Verify imports compile**

```bash
PYTHONPATH=. python -c "from fuzzer.executor.dut_executor import _run_dut_tests_with_feedback, _build_bundle; print('imports OK')"
```

- [ ] **Step 4: Commit**

```bash
git add fuzzer/executor/dut_executor.py
git commit -m "feat: replace single-process feedback loop with Manager-Worker batch loop"
```

---

### Task 9: Update run_dut.py for queue persistence and full param passing

**Files:**
- Modify: `fuzzer/run_dut.py`

- [ ] **Step 1: Add queue_state.json loading**

In `main()`, after the campaign_state bootstrap (already added in earlier fix), add queue restore:

```python
# After campaign state bootstrap
queue_state_path = corpus_dir / "queue_state.json"
if queue_state_path.exists():
    scheduler.restore(queue_state_path)
    global_logger.info(f"Restored queue state with {len(scheduler)} seeds")
```

- [ ] **Step 2: Add queue_state.json saving**

After `corpus.dump_campaign_state()`, add:

```python
scheduler.dump_queue(corpus_dir / "queue_state.json")
global_logger.info(f"Queue state saved to {corpus_dir / 'queue_state.json'}")
```

- [ ] **Step 3: Remove the `corpus_dir` re-initialization from P8**

The P8 persistence block currently re-creates `corpus_dir`. Since it's already created in P0.1, merge them:

```python
# P0.1 + P8 merged (at end of try block):
corpus.dump_campaign_state(corpus_dir / "campaign_state.json")
corpus.dump_state(corpus_dir / "corpus_state.json")
scheduler.dump_queue(corpus_dir / "queue_state.json")
global_logger.info(f"State saved to {corpus_dir}")
```

- [ ] **Step 4: Verify**

```bash
PYTHONPATH=. python -c "from fuzzer.run_dut import main; print('imports OK')"
```

- [ ] **Step 5: Commit**

```bash
git add fuzzer/run_dut.py
git commit -m "feat: add queue_state.json persistence to run_dut"
```

---

### Task 10: Integration tests — full flow + FitnessCalculator + snapshot delta

**Files:**
- Modify: `fuzzer/tests/test_feedback_loop.py`

- [ ] **Step 1: Add TestFitnessCalculator tests**

```python
class TestFitnessCalculator:
    def test_evaluate_with_coverage(self):
        from fuzzer.core.fitness import FitnessCalculator, SeedFitness
        calc = FitnessCalculator()
        category_deltas = {
            "privilege": {"new": 2, "total": 3},
            "float": {"new": 0, "total": 0},
            "control": {"new": 1, "total": 2},
        }
        fitness = calc.evaluate(
            category_deltas=category_deltas,
            diff_families=["fp_rounding"],
            exploration_score=0.75,
            lineage_parent=None,
        )
        assert fitness.exploration_score == 0.75
        assert fitness.diff_diversity == 1
        assert fitness.lineage_depth == 0
        assert fitness.category_affinity["privilege"] > 0
        assert fitness.category_affinity["float"] == 0.0

    def test_evaluate_with_parent_lineage(self):
        from fuzzer.core.fitness import FitnessCalculator, SeedFitness
        calc = FitnessCalculator()
        parent = SeedFitness(
            seed="p1", category_affinity={"privilege": 0.8},
            novelty_score=5.0, diff_diversity=2.0,
            exploration_score=0.6, lineage_depth=3,
        )
        fitness = calc.evaluate(
            category_deltas={"privilege": {"new": 3, "total": 5}},
            diff_families=["csr_write"],
            exploration_score=0.9,
            lineage_parent=parent,
        )
        # lineage_depth = parent + 1
        assert fitness.lineage_depth == 4

    def test_dominant_category(self):
        from fuzzer.core.fitness import FitnessCalculator
        calc = FitnessCalculator()
        cat = calc.dominant_category({
            "privilege": {"new": 1, "total": 5},
            "memory": {"new": 4, "total": 6},
        })
        assert cat == "memory"

    def test_evaluate_empty_inputs(self):
        from fuzzer.core.fitness import FitnessCalculator
        calc = FitnessCalculator()
        fitness = calc.evaluate(
            category_deltas={},
            diff_families=[],
            exploration_score=0.0,
            lineage_parent=None,
        )
        assert fitness.novelty_score == 0.0
        assert fitness.diff_diversity == 0.0
```

- [ ] **Step 2: Add TestSnapshotDelta tests**

```python
class TestSnapshotDelta:
    def test_snapshot_delta_all_new(self):
        from fuzzer.core.corpus import RunCorpus
        corpus = RunCorpus()
        snap = corpus.snapshot()
        transitions = [
            {"csr": "privilege", "prev_value": "a", "curr_value": "b",
             "instr": "csrrs:0x342", "category": "privilege"},
        ]
        delta = corpus.preview_delta_from_snapshot(snap, transitions)
        assert delta["new_coverage"] == 1
        assert delta["total_coverage"] == 1

    def test_snapshot_delta_all_seen(self):
        from fuzzer.core.corpus import RunCorpus
        corpus = RunCorpus()
        corpus._seen_coverage_points.add("privilege|csrrs")
        snap = corpus.snapshot()
        transitions = [
            {"csr": "privilege", "prev_value": "a", "curr_value": "b",
             "instr": "csrrs:0x342", "category": "privilege"},
        ]
        delta = corpus.preview_delta_from_snapshot(snap, transitions)
        assert delta["new_coverage"] == 0
```

- [ ] **Step 3: Run all 28 tests**

```bash
PYTHONPATH=. python -m pytest fuzzer/tests/test_feedback_loop.py -v
```
Expected: 28 tests PASS (22 original + 6 new)

- [ ] **Step 4: Commit**

```bash
git add fuzzer/tests/test_feedback_loop.py
git commit -m "test: add FitnessCalculator, snapshot delta, and pop_best tests"
```

---

### Task 11: End-to-end smoke test

- [ ] **Step 1: Run with small batch_size to verify the loop works**

```bash
cd fuzzer && PYTHONPATH=.. python run_dut.py --config ../configs/rocket_feedback.yaml 2>&1 | head -50
```

Expected: No traceback, "Feedback loop initialized", "Batch 0: dispatching N seeds", "Campaign state saved"

- [ ] **Step 2: Verify campaign_state.json and queue_state.json are created**

```bash
ls -la fuzzer/divefuzz-rocket-corpus/campaign_state.json fuzzer/divefuzz-rocket-corpus/queue_state.json
```

- [ ] **Step 3: Verify seeds/ directory structure**

```bash
ls fuzzer/divefuzz-rocket-corpus/seeds/ | head -20
```

- [ ] **Step 4: Commit any fixes if needed**

```bash
git add -A
git commit -m "fix: end-to-end smoke test adjustments"
```
