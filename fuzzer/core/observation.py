from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path
from typing import Any

from fuzzer.core.status import CaseStatus


def _status_of(bundle: Any) -> str:
    if bundle.execute_result is not None:
        return bundle.execute_result.status.value
    if bundle.generate_result is not None:
        return bundle.generate_result.status.value
    return "pending"


def _failure_kind_of(bundle: Any) -> str | None:
    if bundle.execute_result is not None and bundle.execute_result.failure_kind is not None:
        return bundle.execute_result.failure_kind.value
    if bundle.generate_result is not None and bundle.generate_result.failure_kind is not None:
        return bundle.generate_result.failure_kind.value
    return None


def _message_of(bundle: Any) -> str:
    if bundle.execute_result is not None:
        return bundle.execute_result.message
    if bundle.generate_result is not None:
        return bundle.generate_result.message
    return ""


def _failure_signature_id(status: str, failure_kind: str | None, message: str) -> str:
    raw = f"{status}|{failure_kind or 'none'}|{message.strip()}"
    return hashlib.sha1(raw.encode("utf-8")).hexdigest()


def _build_metrics(
    status: str,
    duration_s: float,
    coverage_point_count: int,
    coverage_new_points: int,
    coverage_delta_ratio: float,
    difftest_unique_events: int,
    difftest_total_events: int,
    unique_pc_pages: int,
) -> dict[str, float]:
    if coverage_point_count > 0:
        coverage_delta_score = max(coverage_delta_ratio, 1.0 if coverage_new_points > 0 else 0.0)
        rare_coverage_score = min(1.0, 0.2 + coverage_delta_ratio)
    else:
        coverage_delta_score = 0.0
        rare_coverage_score = 0.0
    diff_novelty_score = 1.0 if status == CaseStatus.DIFF_FAILED.value else 0.0
    behavior_novelty_score = 1.0 if status in {
        CaseStatus.DIFF_FAILED.value,
        CaseStatus.BADTRAP.value,
        CaseStatus.REFERENCE_FAILED.value,
        CaseStatus.TIMEOUT.value,
    } else 0.0
    event_diversity = min(1.0, difftest_unique_events / 8.0)
    page_diversity = min(1.0, unique_pc_pages / 16.0)
    event_volume = min(1.0, (math.log2(max(1, difftest_total_events))) / 8.0)
    state_novelty_score = min(1.0, 0.5 * event_diversity + 0.3 * page_diversity + 0.2 * event_volume)
    execution_cost_score = min(1.0, duration_s / 60.0)
    failure_severity_score = _severity_of(status)

    return {
        "coverage_delta_score": coverage_delta_score,
        "rare_coverage_score": rare_coverage_score,
        "diff_novelty_score": diff_novelty_score,
        "behavior_novelty_score": behavior_novelty_score,
        "state_novelty_score": state_novelty_score,
        "execution_cost_score": execution_cost_score,
        "failure_severity_score": failure_severity_score,
    }


def _severity_of(status: str) -> float:
    if status == CaseStatus.DIFF_FAILED.value:
        return 1.0
    if status in {CaseStatus.BADTRAP.value, CaseStatus.REFERENCE_FAILED.value}:
        return 0.9
    if status in {CaseStatus.TIMEOUT.value, CaseStatus.COVERAGE_FAILED.value}:
        return 0.6
    if status in {CaseStatus.GENERATION_FAILED.value, CaseStatus.INVALID_PROGRAM.value, CaseStatus.INFRA_ERROR.value}:
        return 0.4
    if status == CaseStatus.EXECUTED.value:
        return 0.0
    return 0.2


CSR_CATEGORIES: dict[str, set[str]] = {
    "privilege": {"mstatus", "mcause", "scause", "medeleg", "mideleg", "sstatus"},
    "float":     {"frm", "fflags", "fcsr"},
    "control":   {"mepc", "sepc", "mtvec", "stvec", "mtval", "stval", "mscratch", "sscratch"},
    "memory":    {"satp", "pmpcfg0", "pmpcfg1", "pmpcfg2", "pmpcfg3",
                  "pmpaddr0", "pmpaddr1", "pmpaddr2", "pmpaddr3", "pmpaddr4",
                  "pmpaddr5", "pmpaddr6", "pmpaddr7", "pmpaddr8", "pmpaddr9",
                  "pmpaddr10", "pmpaddr11", "pmpaddr12", "pmpaddr13", "pmpaddr14", "pmpaddr15"},
    "counter":   {"cycle", "instret", "mcycle", "minstret", "mcounteren", "scounteren",
                  "mhpmevent3", "mhpmevent4", "mhpmevent5", "mhpmevent6", "mhpmevent7",
                  "mhpmevent8", "mhpmevent9", "mhpmevent10", "mhpmevent11", "mhpmevent12",
                  "mhpmevent13", "mhpmevent14", "mhpmevent15", "mhpmevent16", "mhpmevent17",
                  "mhpmevent18", "mhpmevent19", "mhpmevent20", "mhpmevent21", "mhpmevent22",
                  "mhpmevent23", "mhpmevent24", "mhpmevent25", "mhpmevent26", "mhpmevent27",
                  "mhpmevent28", "mhpmevent29", "mhpmevent30", "mhpmevent31"},
}

_CSR_WRITE_INSTRS = {"csrw", "csrwi", "csrs", "csrc", "csrsi", "csrci"}


def _category_for(csr_name: str) -> str:
    for category, names in CSR_CATEGORIES.items():
        if csr_name in names:
            return category
    return "misc"


def classify_transition(csr_name: str) -> str:
    return _category_for(csr_name)


def _serialize_transition(csr: str, prev_value: str, curr_value: str, instr: str) -> str:
    return f"{csr}|{prev_value}|{curr_value}|{instr}"


def _parse_cov_field(cov: str) -> tuple[str, str, str, str] | None:
    """Parse a cov field like 'csr:mstatus:0x0000000a00000000->0x0000000a00001800:csrw'
    into (csr_name, prev_value, curr_value, instr_mnemonic)."""
    parts = cov.split(":")
    if len(parts) < 4 or parts[0] != "csr":
        return None
    csr_name = parts[1]
    transition = parts[2]
    instr = parts[3] if len(parts) > 3 else "unknown"
    if "->" not in transition:
        return None
    prev_str, curr_str = transition.split("->", 1)
    prev_clean = prev_str.replace("0x", "").strip()
    curr_clean = curr_str.replace("0x", "").strip()
    if not prev_clean or not curr_clean:
        return None
    if prev_clean == curr_clean:
        return None
    return (csr_name, prev_clean, curr_clean, instr)


def _is_trivial_csr_write(
    csr_name: str,
    prev_state: dict[str, str],
    curr_state: dict[str, str],
    instr: str,
) -> bool:
    """A CSR write is trivial if the instruction targets this CSR and
    no other CSR changed value."""
    if instr not in _CSR_WRITE_INSTRS:
        return False
    changed_csrs = {
        name for name in set(prev_state) | set(curr_state)
        if prev_state.get(name, "") != curr_state.get(name, "")
    }
    return changed_csrs == {csr_name}


def extract_csr_transitions(observation_path: Path | None) -> list[dict[str, Any]]:
    """Extract CSR transition triples from a DiffTest JSONL observation file.

    Returns list of dicts with keys: csr, prev_value, curr_value, instr, category.
    Filters trivial CSR-write transitions where only the target CSR changed.
    """
    if observation_path is None or not observation_path.exists():
        return []
    transitions: list[dict[str, Any]] = []
    csr_state: dict[str, str] = {}
    try:
        fp = observation_path.open("r", encoding="utf-8", errors="ignore")
    except OSError:
        return []
    with fp:
        for line in fp:
            text = line.strip()
            if not text:
                continue
            try:
                payload = json.loads(text)
            except json.JSONDecodeError:
                continue
            event = str(payload.get("event", ""))
            if event != "coverage":
                continue
            cov = payload.get("cov")
            if not isinstance(cov, str) or not cov.strip():
                continue
            parsed = _parse_cov_field(cov.strip())
            if parsed is None:
                continue
            csr_name, prev_clean, curr_clean, instr = parsed
            if csr_name in csr_state and _is_trivial_csr_write(csr_name, csr_state, {csr_name: curr_clean}, instr):
                continue
            csr_state[csr_name] = curr_clean
            category = _category_for(csr_name)
            transitions.append({
                "csr": csr_name,
                "prev_value": prev_clean,
                "curr_value": curr_clean,
                "instr": instr,
                "category": category,
            })
    return transitions


def build_transition_cooccurrence(transitions: list[dict[str, Any]]) -> dict[str, dict[str, int]]:
    """Stub for Plan 5: instruction-transition co-occurrence matrix.
    Returns empty dict until full implementation."""
    return {}


def extract_transition_paths(transitions: list[dict[str, Any]], window: int = 2) -> list[str]:
    """Stub for Plan 6: sliding-window transition path coverage.
    Returns empty list until full implementation."""
    return []


DIFF_FAMILIES: dict[str, str] = {
    "fp_rounding":      "FP CSR changed, writeback difference <= 2 ulp",
    "fp_nan":           "FP register value NaN in one model but not the other",
    "csr_write":        "Instruction is csrw/csrwi/csrs/csrc, CSR value mismatch",
    "trap_difference":  "mcause or scause differs between ISA and RTL",
    "pc_divergence":    "PC differs by > 4 bytes",
    "memory_ordering":  "Instruction is lr/sc/amo/fence, ordering or reservation mismatch",
    "unknown":          "None of the above",
}

_FP_INSTRS = {
    "fadd.s", "fsub.s", "fmul.s", "fdiv.s", "fsqrt.s", "fmadd.s", "fmsub.s",
    "fnmadd.s", "fnmsub.s", "fadd.d", "fsub.d", "fmul.d", "fdiv.d", "fsqrt.d",
    "fmadd.d", "fmsub.d", "fnmadd.d", "fnmsub.d", "fcvt.w.s", "fcvt.wu.s",
    "fcvt.s.w", "fcvt.s.wu", "fcvt.l.s", "fcvt.lu.s", "fcvt.s.l", "fcvt.s.lu",
    "fcvt.w.d", "fcvt.wu.d", "fcvt.d.w", "fcvt.d.wu", "fcvt.l.d", "fcvt.lu.d",
    "fcvt.d.l", "fcvt.d.lu", "fcvt.s.d", "fcvt.d.s", "fmin.s", "fmax.s",
    "fmin.d", "fmax.d", "fsgnj.s", "fsgnjn.s", "fsgnjx.s", "fsgnj.d",
    "fsgnjn.d", "fsgnjx.d", "feq.s", "flt.s", "fle.s", "feq.d", "flt.d", "fle.d",
    "fclass.s", "fclass.d", "fmv.x.w", "fmv.w.x", "fmv.x.d", "fmv.d.x",
    "flw", "fsw", "fld", "fsd",
}

_MEMORY_INSTRS = {"lr.w", "lr.d", "sc.w", "sc.d", "amoswap.w", "amoswap.d",
                  "amoadd.w", "amoadd.d", "amoxor.w", "amoxor.d",
                  "amoand.w", "amoand.d", "amoor.w", "amoor.d",
                  "amomin.w", "amomin.d", "amomax.w", "amomax.d",
                  "amominu.w", "amominu.d", "amomaxu.w", "amomaxu.d",
                  "fence", "fence.i", "sfence.vma"}


def _classify_single_diff(payload: dict[str, Any]) -> str:
    """Classify a single diff event payload into a diff family."""
    cov = payload.get("cov")
    instr = ""
    csr_name = ""
    if isinstance(cov, str):
        parts = cov.split(":")
        if len(parts) >= 4:
            csr_name = parts[1]
            instr = parts[3] if len(parts) > 3 else ""

    instr_lower = instr.lower()

    # FP CSR with FP instruction → fp_rounding or fp_nan
    if csr_name in {"fflags", "frm", "fcsr"} and instr_lower in _FP_INSTRS:
        sev = str(payload.get("severity", "")).lower()
        msg = str(payload.get("message", "")).lower()
        if "nan" in sev or "nan" in msg:
            return "fp_nan"
        return "fp_rounding"

    # CSR write instruction → csr_write
    if instr_lower in {"csrw", "csrwi", "csrs", "csrc", "csrsi", "csrci"}:
        return "csr_write"

    # Memory ordering instructions → memory_ordering
    if instr_lower in _MEMORY_INSTRS:
        return "memory_ordering"

    # mcause/scause present → trap_difference
    if "mcause" in payload or "scause" in payload:
        return "trap_difference"

    # PC field present → pc_divergence
    if "pc" in payload:
        return "pc_divergence"

    return "unknown"


def classify_diff_family(observation_path: Path | None) -> list[str]:
    """Extract diff family classifications from a DiffTest JSONL observation file.

    Returns list of family labels (one per diff/error event).
    Only processes events with severity='error'/'fatal' or event='mismatch'.
    """
    if observation_path is None or not observation_path.exists():
        return []
    families: list[str] = []
    try:
        fp = observation_path.open("r", encoding="utf-8", errors="ignore")
    except OSError:
        return []
    with fp:
        for line in fp:
            text = line.strip()
            if not text:
                continue
            try:
                payload = json.loads(text)
            except json.JSONDecodeError:
                continue
            severity = str(payload.get("severity", "")).lower()
            event = str(payload.get("event", "")).lower()
            if severity not in {"error", "fatal"} and event != "mismatch":
                continue
            family = _classify_single_diff(payload)
            families.append(family)
    return families
