from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass
class ObservationData:
    transitions: list[dict[str, Any]]
    diff_families: list[str]


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

def _category_for(csr_name: str) -> str:
    for category, names in CSR_CATEGORIES.items():
        if csr_name in names:
            return category
    return "misc"


CSR_WRITE_MNEMONICS: set[str] = {"csrrw", "csrrs", "csrrc", "csrrwi", "csrrsi", "csrci"}

TRIVIAL_CSR_CATEGORIES: set[str] = {"privilege", "float"}


def make_coverage_key(transition: dict[str, Any]) -> str:
    """Build a category-level coverage key: {category}|{mnemonic}.

    Unlike _serialize_transition (which includes actual CSR register values),
    this produces coarse-grained keys suitable for coverage dedup across
    different programs that exercise the same CSR category with the same
    instruction type.
    """
    category = transition.get("category", "misc")
    instr = transition.get("instr", "")
    mnemonic = instr.split(":")[0] if ":" in instr else instr
    return f"{category}|{mnemonic}"


def _is_trivial_csr_write(mnemonic: str, category: str) -> bool:
    """Return True if this is a trivial CSR-write transition that should be filtered.

    Filter rationale (from ProcessorFuzz): CSR-write instructions (csrrw/csrrs/
    csrrc/csrrwi/csrrsi/csrci) that modify a commonly-written CSR register
    produce their primary intended effect. The interesting coverage signal comes
    from *side effects* — non-CSR instructions that happen to alter CSR state
    (e.g. FP ops modifying fflags, traps changing mcause).
    """
    return mnemonic in CSR_WRITE_MNEMONICS and category in TRIVIAL_CSR_CATEGORIES


def classify_transition(csr_name: str) -> str:
    return _category_for(csr_name)


def _serialize_transition(csr: str, prev_value: str, curr_value: str, instr: str) -> str:
    return f"{csr}|{prev_value}|{curr_value}|{instr}"


def _parse_cov_field(cov: str) -> tuple[str, str, str, str] | None:
    """Parse a cov field into (category, prev_vec, curr_vec, instr_tag).

    Emulator format (difftest.cpp):
      csr:{category}:{mnemonic}:{addr}:{vec_before}->{vec_after}

    Examples:
      csr:priv:csrrs:0x342:0x800...00,0x0,...->0x800...00,0x2,...
      csr:priv:opc:0x73:0x800...00,0x0,...->0x800...80,0x2,...

      → ("privilege", "0x800...00,0x0,...", "0x800...00,0x2,...", "csrrs:0x342")

    Category mapping: "priv" → "privilege", "float" → "float"
    """
    if not cov.startswith("csr:"):
        return None
    content = cov[4:]  # strip "csr:" prefix
    parts = content.split(":", 3)  # category, mnemonic, addr, rest
    if len(parts) < 4:
        return None
    category_raw, mnemonic, addr, rest = parts
    if "->" not in rest:
        return None
    prev_str, curr_str = rest.split("->", 1)
    prev_vec = prev_str.strip()
    curr_vec = curr_str.strip()
    if not prev_vec or not curr_vec:
        return None
    if prev_vec == curr_vec:
        return None
    category = "privilege" if category_raw == "priv" else category_raw
    instr_tag = f"{mnemonic}:{addr}"
    return (category, prev_vec, curr_vec, instr_tag)


def extract_csr_transitions(observation_path: Path | None) -> list[dict[str, Any]]:
    """Extract CSR transition vectors from a DiffTest JSONL observation file.

    Returns list of dicts with keys: csr (category), prev_value, curr_value, instr, category.
    The emulator (difftest.cpp) already filters trivial CSR-write transitions.
    """
    if observation_path is None or not observation_path.exists():
        return []
    transitions: list[dict[str, Any]] = []
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
            category, prev_vec, curr_vec, instr_tag = parsed
            mnemonic = instr_tag.split(":")[0] if ":" in instr_tag else instr_tag
            if _is_trivial_csr_write(mnemonic, category):
                continue
            transitions.append({
                "csr": category,
                "prev_value": prev_vec,
                "curr_value": curr_vec,
                "instr": instr_tag,
                "category": category,
            })
    return transitions


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


def parse_observation(observation_path: Path | None) -> ObservationData:
    """Single-pass parse of a DiffTest JSONL observation file.

    Extracts both CSR transitions and diff family classifications in one
    file scan, avoiding the double I/O of calling extract_csr_transitions()
    and classify_diff_family() separately.
    """
    if observation_path is None or not observation_path.exists():
        return ObservationData(transitions=[], diff_families=[])

    transitions: list[dict[str, Any]] = []
    diff_families: list[str] = []

    try:
        fp = observation_path.open("r", encoding="utf-8", errors="ignore")
    except OSError:
        return ObservationData(transitions=[], diff_families=[])
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

            # --- coverage events: CSR transitions ---
            if event == "coverage":
                cov = payload.get("cov")
                if isinstance(cov, str) and cov.strip():
                    parsed = _parse_cov_field(cov.strip())
                    if parsed is not None:
                        category, prev_vec, curr_vec, instr_tag = parsed
                        mnemonic = instr_tag.split(":")[0] if ":" in instr_tag else instr_tag
                        if _is_trivial_csr_write(mnemonic, category):
                            continue
                        transitions.append({
                            "csr": category,
                            "prev_value": prev_vec,
                            "curr_value": curr_vec,
                            "instr": instr_tag,
                            "category": category,
                        })

            # --- error/mismatch events: diff families ---
            else:
                severity = str(payload.get("severity", "")).lower()
                if severity in {"error", "fatal"} or event.lower() == "mismatch":
                    family = _classify_single_diff(payload)
                    diff_families.append(family)

    return ObservationData(transitions=transitions, diff_families=diff_families)
