from __future__ import annotations

from dataclasses import dataclass
from typing import Any


def emit_morph_event(pc: str, orig_inst: str, mutated_inst: str, cycle: int, instr: int) -> dict[str, Any]:
    return {"event": "morph", "pc": pc, "orig_inst": orig_inst,
            "mutated_inst": mutated_inst, "cycle": cycle, "instr": instr}


def emit_sync_event(sync_type: str, target: str, dut_value: str, ref_value: str,
                    reason: str, pc: str, cycle: int, instr: int) -> dict[str, Any]:
    return {"event": "sync", "type": sync_type, "target": target,
            "dut_value": dut_value, "ref_value": ref_value,
            "reason": reason, "pc": pc, "cycle": cycle, "instr": instr}


def emit_strategy_event(strategy: str, seed: str) -> dict[str, Any]:
    return {"event": "morph_strategy", "strategy": strategy, "seed": seed}


@dataclass
class SyncDecision:
    family: str
    decision: str  # "syncable" | "potential_bug"
    reason: str
    csr: str | None = None
    pc: str | None = None


_CSR_WRITE_SYNCABLE_CSRS = {"mstatus", "sstatus", "fflags", "frm", "fcsr"}


class SyncDecisionEngine:
    def classify(self, diff_events: list[dict[str, Any]]) -> list[SyncDecision]:
        decisions: list[SyncDecision] = []
        for event in diff_events:
            family = str(event.get("family", "unknown"))
            cov = event.get("cov", "")
            csr_name = ""
            if isinstance(cov, str) and ":" in cov:
                parts = cov.split(":")
                if len(parts) >= 2:
                    csr_name = parts[1]

            if family == "csr_write":
                if csr_name in _CSR_WRITE_SYNCABLE_CSRS:
                    if csr_name in {"mstatus", "sstatus"}:
                        decisions.append(SyncDecision(
                            family=family, decision="syncable",
                            reason="FS field implementation difference", csr=csr_name))
                    elif csr_name in {"fflags", "fcsr"}:
                        decisions.append(SyncDecision(
                            family=family, decision="syncable",
                            reason="FP CSR implementation difference", csr=csr_name))
                    elif csr_name in {"frm"}:
                        decisions.append(SyncDecision(
                            family=family, decision="syncable",
                            reason="Rounding mode implementation difference", csr=csr_name))
                elif csr_name in {"sepc", "mepc"}:
                    decisions.append(SyncDecision(
                        family=family, decision="potential_bug",
                        reason=f"LSB of {csr_name} may be non-zero", csr=csr_name))
                elif csr_name == "mhartid":
                    decisions.append(SyncDecision(
                        family=family, decision="potential_bug",
                        reason="mhartid should be read-only zero", csr=csr_name))
                else:
                    decisions.append(SyncDecision(
                        family=family, decision="potential_bug",
                        reason=f"CSR write mismatch on {csr_name}", csr=csr_name))
            elif family == "fp_rounding":
                decisions.append(SyncDecision(
                    family=family, decision="syncable",
                    reason="FP rounding +/-1ulp", csr=csr_name))
            elif family == "fp_nan":
                decisions.append(SyncDecision(
                    family=family, decision="syncable",
                    reason="Both sides NaN", csr=csr_name))
            elif family == "trap_difference":
                mcause_isa = event.get("mcause_isa", "")
                mcause_rtl = event.get("mcause_rtl", "")
                if mcause_isa and mcause_rtl and mcause_isa == mcause_rtl:
                    decisions.append(SyncDecision(
                        family=family, decision="syncable",
                        reason="Same exception type, timing difference"))
                else:
                    decisions.append(SyncDecision(
                        family=family, decision="potential_bug",
                        reason="Different exception types"))
            else:
                decisions.append(SyncDecision(
                    family=family, decision="potential_bug",
                    reason=f"Unclassified {family} mismatch"))
        return decisions

    def summary(self, decisions: list[SyncDecision]) -> dict[str, Any]:
        syncable_count = sum(1 for d in decisions if d.decision == "syncable")
        bug_count = sum(1 for d in decisions if d.decision == "potential_bug")
        by_family: dict[str, dict[str, int]] = {}
        for d in decisions:
            bucket = by_family.setdefault(d.family, {"syncable": 0, "potential_bug": 0})
            bucket[d.decision] += 1
        return {
            "syncable_count": syncable_count,
            "potential_bug_count": bug_count,
            "by_family": by_family,
        }
