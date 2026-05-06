from __future__ import annotations

import hashlib
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from fuzzer.core.fitness import SeedFitness
from fuzzer.core.status import CaseStatus
from fuzzer.utils.serde import dump_json


# ---------------------------------------------------------------------------
# Compatibility helpers — work with both CaseBundle (object attributes) and
# plain dicts, so the same RunCorpus code can be used in both RVFUZZ and
# DiveFuzz environments.
# ---------------------------------------------------------------------------

def _get(obj: Any, name: str, default: Any = None) -> Any:
    """Get attribute from an object or a dict key."""
    if obj is None:
        return default
    if isinstance(obj, dict):
        return obj.get(name, default)
    return getattr(obj, name, default)


def _set(obj: Any, name: str, value: Any) -> None:
    """Set attribute on an object or a dict key."""
    if isinstance(obj, dict):
        obj[name] = value
    else:
        setattr(obj, name, value)


# ---------------------------------------------------------------------------
# Data types
# ---------------------------------------------------------------------------

@dataclass
class CorpusEntry:
    case_id: str
    seed: str | None
    status: str
    failure_kind: str | None
    signature: str
    decision: str
    queue: str | None
    lineage_parent: str | None
    manifest_path: str
    coverage_new_points: int
    coverage_total_points: int
    coverage_delta_ratio: float


@dataclass
class RunCorpus:
    initial_corpus: list[str] = field(default_factory=list)
    max_retained: int = 1024
    entries: list[CorpusEntry] = field(default_factory=list)
    consumed_seeds: list[str] = field(default_factory=list)
    retained_seeds: set[str] = field(default_factory=set)
    _retained_seed_order: list[str] = field(default_factory=list)
    _seen_signatures: set[str] = field(default_factory=set)
    _seen_coverage_points: set[str] = field(default_factory=set)
    _seen_transitions: set[str] = field(default_factory=set)
    _seen_transitions_by_category: dict[str, set[str]] = field(default_factory=dict)
    _transition_frequency: dict[str, int] = field(default_factory=dict)
    _seen_diff_signatures: dict[str, set[str]] = field(default_factory=dict)
    _diff_family_counts: dict[str, int] = field(default_factory=dict)
    _seed_fitness: dict[str, SeedFitness] = field(default_factory=dict)

    def preview_coverage_delta(self, bundle: Any) -> dict[str, float | int]:
        points = self._collect_coverage_points(bundle)
        new_points = points - self._seen_coverage_points
        total = len(points)
        new_count = len(new_points)
        ratio = (new_count / float(total)) if total else 0.0
        return {
            "new_points": new_count,
            "total_points": total,
            "delta_ratio": ratio,
        }

    def record(self, bundle: Any) -> CorpusEntry:
        status = self._status_of(bundle)
        failure_kind = self._failure_kind_of(bundle)
        signature = self._signature_of(bundle, status, failure_kind)
        coverage_points = self._collect_coverage_points(bundle)
        new_coverage_points = coverage_points - self._seen_coverage_points
        self._seen_coverage_points.update(coverage_points)
        transitions = self._collect_transitions(bundle)
        if transitions:
            self.record_transitions(transitions)
        coverage_total_points = len(coverage_points)
        coverage_new_count = len(new_coverage_points)
        coverage_delta_ratio = (coverage_new_count / float(coverage_total_points)) if coverage_total_points else 0.0
        _set(bundle, "coverage_new_points", coverage_new_count)
        _set(bundle, "coverage_total_points", coverage_total_points)
        _set(bundle, "coverage_delta_ratio", coverage_delta_ratio)

        if signature in self._seen_signatures:
            decision = "archive_only"
            queue = "exploration"
        elif status in {
            CaseStatus.DIFF_FAILED.value,
            CaseStatus.REFERENCE_FAILED.value,
            CaseStatus.COVERAGE_FAILED.value,
            CaseStatus.BADTRAP.value,
            CaseStatus.TIMEOUT.value,
        }:
            decision = "promote_mutation"
            queue = "bug_proximity"
        elif status == CaseStatus.EXECUTED.value and coverage_new_count > 0:
            decision = "promote_mutation"
            queue = "stable_ancestor"
        elif status == CaseStatus.EXECUTED.value:
            decision = "keep_in_corpus"
            queue = "exploration"
        else:
            decision = "discard"
            queue = "exploration"

        feedback_decision = _get(bundle, "feedback_decision")
        if feedback_decision is not None and decision != "archive_only":
            decision = feedback_decision
            queue = _get(bundle, "feedback_queue") or queue
        self._seen_signatures.add(signature)
        seed = _get(bundle, "seed")
        if seed is not None:
            self.consumed_seeds.append(seed)

        case_root = _get(bundle, "case_root")
        if case_root is not None:
            manifest_path = str(Path(str(case_root)) / "case_manifest.json")
        else:
            manifest_path = ""

        entry = CorpusEntry(
            case_id=_get(bundle, "case_id", ""),
            seed=seed,
            status=status,
            failure_kind=failure_kind,
            signature=signature,
            decision=decision,
            queue=queue,
            lineage_parent=_get(bundle, "lineage_parent") or (f"seed:{seed}" if seed else None),
            manifest_path=manifest_path,
            coverage_new_points=coverage_new_count,
            coverage_total_points=coverage_total_points,
            coverage_delta_ratio=coverage_delta_ratio,
        )
        self.entries.append(entry)
        if decision in {"keep_in_corpus", "promote_mutation"} and seed:
            self._retain_seed(seed)
        return entry

    def preview_transition_delta_from_transitions(
        self, transitions: list[dict[str, Any]]
    ) -> dict[str, Any]:
        from fuzzer.core.observation import _serialize_transition

        new_keys: set[str] = set()
        all_keys: set[str] = set()
        by_category: dict[str, dict[str, int]] = {}
        for t in transitions:
            key = _serialize_transition(
                t["csr"], t["prev_value"], t["curr_value"], t["instr"]
            )
            all_keys.add(key)
            if key not in self._seen_transitions:
                new_keys.add(key)
            cat = t.get("category", "misc")
            bucket = by_category.setdefault(cat, {"new": 0, "total": 0})
            bucket["total"] += 1
            if key not in self._seen_transitions:
                bucket["new"] += 1
        total = len(all_keys)
        new_count = len(new_keys)
        return {
            "new_transitions": new_count,
            "total_transitions": total,
            "delta_ratio": (new_count / float(total)) if total else 0.0,
            "by_category": by_category,
        }

    def preview_transition_delta(self, bundle: Any) -> dict[str, Any]:
        transitions = self._collect_transitions(bundle)
        return self.preview_transition_delta_from_transitions(transitions)

    def record_transitions(self, transitions: list[dict[str, Any]]) -> dict[str, Any]:
        from fuzzer.core.observation import _serialize_transition

        new_keys: set[str] = set()
        by_category: dict[str, dict[str, int]] = {}
        for t in transitions:
            key = _serialize_transition(
                t["csr"], t["prev_value"], t["curr_value"], t["instr"]
            )
            cat = t.get("category", "misc")
            bucket = by_category.setdefault(cat, {"new": 0, "total": 0})
            bucket["total"] += 1
            if key not in self._seen_transitions:
                new_keys.add(key)
                bucket["new"] += 1
            self._seen_transitions.add(key)
            cat_set = self._seen_transitions_by_category.setdefault(cat, set())
            cat_set.add(key)
            self._transition_frequency[key] = self._transition_frequency.get(key, 0) + 1
        return {
            "new_transitions": len(new_keys),
            "total_transitions": len(transitions),
            "by_category": by_category,
        }

    def get_transition_rarity(self, key: str) -> float:
        import math

        freq = self._transition_frequency.get(key, 0)
        if freq == 0:
            return 1.0
        return 1.0 / (1.0 + math.log2(1.0 + float(freq)))

    def preview_diff_delta(self, families: list[str]) -> dict[str, Any]:
        """Preview which diff families are new vs already seen."""
        unique = list(dict.fromkeys(families))
        new_fams = [f for f in unique if f not in self._seen_diff_signatures]
        return {
            "new_families": new_fams,
            "total_families": len(unique),
            "has_new": len(new_fams) > 0,
        }

    def record_diff_families(
        self, families: list[str], case_id: str
    ) -> list[str]:
        """Record diff families for dedup. Returns list of newly discovered families."""
        new_fams: list[str] = []
        for fam in families:
            sig_set = self._seen_diff_signatures.setdefault(fam, set())
            sig = f"{fam}:{case_id}"
            if not sig_set:
                new_fams.append(fam)
            sig_set.add(sig)
            self._diff_family_counts[fam] = self._diff_family_counts.get(fam, 0) + 1
        return list(set(new_fams))

    def get_seed_fitness(self, seed: str) -> dict[str, Any]:
        if seed in self._seed_fitness:
            f = self._seed_fitness[seed]
            return {
                "seed": f.seed,
                "category_affinity": f.category_affinity,
                "novelty_score": f.novelty_score,
                "diff_diversity": f.diff_diversity,
                "exploration_score": f.exploration_score,
                "lineage_depth": f.lineage_depth,
            }
        return {
            "seed": str(seed).strip() or "",
            "category_affinity": {c: 0.0 for c in ["privilege","float","control","memory","counter","misc"]},
            "novelty_score": 0.0,
            "diff_diversity": 0.0,
            "exploration_score": 0.0,
            "lineage_depth": 0,
        }

    def update_seed_fitness(self, seed: str, fitness: SeedFitness) -> None:
        self._seed_fitness[str(seed).strip()] = fitness

    def dump_state(self, output_path: Path) -> None:
        payload = {
            "initial_corpus": self.initial_corpus,
            "total_recorded": len(self.entries),
            "queue_size": sum(
                1 for item in self.entries if item.decision in {"keep_in_corpus", "promote_mutation"}
            ),
            "archive_only_count": sum(1 for item in self.entries if item.decision == "archive_only"),
            "dedup_signature_count": len(self._seen_signatures),
            "coverage_point_count": len(self._seen_coverage_points),
            "consumed_seeds": self.consumed_seeds,
            "retained_seeds": list(self._retained_seed_order),
            "entries": self.entries,
        }
        dump_json(payload, output_path)

    def dump_campaign_state(self, output_path: Path) -> None:
        payload = {
            "retained_seeds": list(self._retained_seed_order),
            "signature_count": len(self._seen_signatures),
            "coverage_point_count": len(self._seen_coverage_points),
            "signatures": sorted(self._seen_signatures),
            "coverage_points": sorted(self._seen_coverage_points),
            "last_run_recorded_cases": len(self.entries),
        }
        transition_count_by_category = {
            cat: len(keys) for cat, keys in self._seen_transitions_by_category.items()
        }
        payload["transition_count"] = len(self._seen_transitions)
        payload["transition_count_by_category"] = transition_count_by_category
        freq_sample = dict(
            sorted(self._transition_frequency.items(), key=lambda x: -x[1])[:1000]
        )
        payload["transition_frequency_sample"] = freq_sample
        payload["diff_family_counts"] = dict(self._diff_family_counts)
        payload["diff_signature_sample"] = {
            fam: sorted(list(sigs))[:200]
            for fam, sigs in self._seen_diff_signatures.items()
        }
        payload["seed_fitness"] = {
            str(s): {
                "category_affinity": dict(f.category_affinity),
                "novelty_score": f.novelty_score,
                "diff_diversity": f.diff_diversity,
                "exploration_score": f.exploration_score,
                "lineage_depth": f.lineage_depth,
            }
            for s, f in self._seed_fitness.items()
        }
        dump_json(payload, output_path)

    def bootstrap_from_campaign_state(self, payload: dict[str, Any]) -> None:
        seeds = payload.get("retained_seeds", [])
        if isinstance(seeds, list):
            for seed in seeds:
                normalized = str(seed).strip()
                if normalized:
                    self._retain_seed(normalized)

        signatures = payload.get("signatures", [])
        if isinstance(signatures, list):
            self._seen_signatures.update(str(item) for item in signatures if str(item).strip())

        coverage_points = payload.get("coverage_points", [])
        if isinstance(coverage_points, list):
            self._seen_coverage_points.update(str(item) for item in coverage_points if str(item).strip())

        from fuzzer.core.observation import classify_transition

        transitions_sample = payload.get("transition_frequency_sample", {})
        if isinstance(transitions_sample, dict):
            for key, count in transitions_sample.items():
                if isinstance(key, str) and isinstance(count, int) and count > 0:
                    self._seen_transitions.add(key)
                    self._transition_frequency[key] = count
                    csr = key.split("|")[0] if "|" in key else "unknown"
                    cat = classify_transition(csr)
                    cat_set = self._seen_transitions_by_category.setdefault(cat, set())
                    cat_set.add(key)

        diff_counts = payload.get("diff_family_counts", {})
        if isinstance(diff_counts, dict):
            for fam, count in diff_counts.items():
                if isinstance(fam, str) and isinstance(count, int) and count > 0:
                    self._diff_family_counts[fam] = count

        diff_sigs = payload.get("diff_signature_sample", {})
        if isinstance(diff_sigs, dict):
            for fam, sigs in diff_sigs.items():
                if isinstance(sigs, list):
                    self._seen_diff_signatures.setdefault(str(fam), set()).update(
                        str(s) for s in sigs if str(s).strip()
                    )

        seed_fitness_data = payload.get("seed_fitness", {})
        if isinstance(seed_fitness_data, dict):
            for s, fdata in seed_fitness_data.items():
                if isinstance(fdata, dict):
                    self._seed_fitness[str(s)] = SeedFitness(
                        seed=str(s),
                        category_affinity=dict(fdata.get("category_affinity", {})),
                        novelty_score=float(fdata.get("novelty_score", 0.0)),
                        diff_diversity=float(fdata.get("diff_diversity", 0.0)),
                        exploration_score=float(fdata.get("exploration_score", 0.0)),
                        lineage_depth=int(fdata.get("lineage_depth", 0)),
                    )

    @staticmethod
    def load_campaign_state(campaign_state_path: Path) -> dict[str, Any]:
        if not campaign_state_path.exists():
            return {}
        try:
            import json

            payload: Any = json.loads(campaign_state_path.read_text(encoding="utf-8"))
        except Exception:
            return {}
        if not isinstance(payload, dict):
            return {}
        seeds = payload.get("retained_seeds", [])
        if isinstance(seeds, list):
            payload["retained_seeds"] = [str(seed).strip() for seed in seeds if str(seed).strip()]
        else:
            payload["retained_seeds"] = []
        return payload

    def _status_of(self, bundle: Any) -> str:
        exec_result = _get(bundle, "execute_result")
        if exec_result is not None:
            status_val = _get(exec_result, "status", "pending")
            return status_val.value if hasattr(status_val, "value") else str(status_val)
        gen_result = _get(bundle, "generate_result")
        if gen_result is not None:
            status_val = _get(gen_result, "status", "pending")
            return status_val.value if hasattr(status_val, "value") else str(status_val)
        return "pending"

    def _failure_kind_of(self, bundle: Any) -> str | None:
        exec_result = _get(bundle, "execute_result")
        if exec_result is not None:
            fk = _get(exec_result, "failure_kind")
            if fk is not None:
                return fk.value if hasattr(fk, "value") else str(fk)
        gen_result = _get(bundle, "generate_result")
        if gen_result is not None:
            fk = _get(gen_result, "failure_kind")
            if fk is not None:
                return fk.value if hasattr(fk, "value") else str(fk)
        return None

    def _signature_of(self, bundle: Any, status: str, failure_kind: str | None) -> str:
        exec_result = _get(bundle, "execute_result")
        if exec_result is not None:
            message = str(_get(exec_result, "message", "")).strip()
            if status == CaseStatus.EXECUTED.value:
                image_path = _get(exec_result, "image_path")
                image_digest = self._digest_image(image_path)
                return f"exec|{status}|{failure_kind or 'none'}|{message}|{image_digest}"
            return f"exec|{status}|{failure_kind or 'none'}|{message}"
        gen_result = _get(bundle, "generate_result")
        if gen_result is not None:
            message = str(_get(gen_result, "message", "")).strip()
            return f"gen|{status}|{failure_kind or 'none'}|{message}"
        return "pending"

    def _collect_coverage_points(self, bundle: Any) -> set[str]:
        points: set[str] = set()
        coverage_result = _get(bundle, "coverage_result")
        if coverage_result is not None:
            raw_points = _get(coverage_result, "points", [])
            for point in raw_points:
                normalized = str(point).strip()
                if normalized:
                    points.add(normalized)
        return points

    def _collect_transitions(self, bundle: Any) -> list[dict[str, Any]]:
        exec_result = _get(bundle, "execute_result")
        if exec_result is not None:
            return _get(exec_result, "csr_transitions") or []
        return []

    def _digest_file(self, path: Path) -> str:
        if isinstance(path, str):
            path = Path(path)
        digest = hashlib.sha1()
        try:
            with path.open("rb") as fp:
                while True:
                    chunk = fp.read(65536)
                    if not chunk:
                        break
                    digest.update(chunk)
        except OSError:
            return f"error:{path}"
        return digest.hexdigest()

    def _digest_image(self, image_path: Any) -> str:
        if image_path is None:
            return "none"
        path = image_path if isinstance(image_path, Path) else Path(str(image_path))
        if not path.exists():
            return "missing"
        return self._digest_file(path)

    def _retain_seed(self, seed: str) -> None:
        normalized = str(seed).strip()
        if not normalized:
            return
        if normalized in self.retained_seeds:
            return
        self.retained_seeds.add(normalized)
        self._retained_seed_order.append(normalized)
        while len(self._retained_seed_order) > max(1, self.max_retained):
            dropped = self._retained_seed_order.pop(0)
            self.retained_seeds.discard(dropped)
