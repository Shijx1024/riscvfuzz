from __future__ import annotations

from enum import Enum


class CaseStatus(str, Enum):
    GENERATED = "generated"
    GENERATION_FAILED = "generation_failed"
    INVALID_PROGRAM = "invalid_program"
    EXECUTED = "executed"
    DIFF_FAILED = "diff_failed"
    REFERENCE_FAILED = "reference_failed"
    BADTRAP = "badtrap"
    TIMEOUT = "timeout"
    INFRA_ERROR = "infra_error"
    COVERAGE_FAILED = "coverage_failed"
    ARCHIVED_NO_NOVELTY = "archived_no_novelty"
    SYNCABLE_NO_BUG = "syncable_no_bug"


class FailureKind(str, Enum):
    GENERATION_ERROR = "generation_error"
    INVALID_PROGRAM = "invalid_program"
    BAD_TRAP = "bad_trap"
    INFRA_ERROR = "infra_error"
    REFERENCE_ERROR = "reference_error"
    DIFF_MISMATCH = "diff_mismatch"
    TIMEOUT = "timeout"
    COVERAGE_COLLECTION_FAILED = "coverage_collection_failed"


class ArtifactKind(str, Enum):
    ASM = "asm"
    BIN = "bin"
    IMG = "img"
    ELF_ALIAS = "elf_alias"
    RAW_ELF = "raw_elf"
    DUMP = "dump"
    SYMBOL = "symbol"
    CMD_HISTORY = "cmd_history"
    COVERAGE_RAW = "coverage_raw"


class RunStatus(str, Enum):
    RUNNING = "running"
    COMPLETED = "completed"
    ABORTED = "aborted"
