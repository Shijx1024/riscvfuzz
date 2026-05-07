from __future__ import annotations

import subprocess
import time
from pathlib import Path
from typing import Any

from fuzzer.core.observation import parse_observation
from fuzzer.core.seed_ref import WorkerTask, WorkerResult
from fuzzer.core.status import CaseStatus, FailureKind


def seed_path(output_dir: Path, seed_id: str) -> Path:
    """Convention: {output_dir}/{seed_id}/seed_0.img"""
    return output_dir / seed_id / "seed_0.img"


def _setup_worker_singletons(allowed_ext_name: str, architecture: str) -> None:
    """Initialize generator module-level singletons inside a worker process.

    These are set by setup_config() in the main process and inherited via
    fork on Linux.  This function ensures compatibility with spawn mode.
    """
    from fuzzer.generator.asm_template_manager.ext_list import allowed_ext
    from fuzzer.generator.bug_filter import bug_filter
    allowed_ext.setup_ext(allowed_ext_name)
    bug_filter.set_architecture(architecture)


def worker_generate(
    *, seed_id: str, output_dir: Path, arch: Any,
    instr_number: int, template_type: str, architecture: str,
    dive_enable: bool, is_rv32: bool,
) -> Path:
    """Generate a single seed program.  Returns path to seed_0.img."""
    from fuzzer.generator.core.generator import generate_instructions_parallel
    from fuzzer.utils.elf_to_img import process_file

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

    # Direct process_file call -- avoids nested ThreadPoolExecutor
    asm_files = list(gen_dir.glob("*.S"))
    if not asm_files:
        raise RuntimeError(f"No .S file generated in {gen_dir}")
    img_dir = gen_dir / "img_file"
    elf_dir = gen_dir / "elf_file"
    img_dir.mkdir(parents=True, exist_ok=True)
    elf_dir.mkdir(parents=True, exist_ok=True)
    process_file(str(asm_files[0].name), str(gen_dir), str(img_dir), str(elf_dir))

    # Find generated .img and rename to canonical seed_0.img
    img_files = list(img_dir.glob("*.img"))
    if not img_files:
        raise RuntimeError(f"No .img file generated in {img_dir}")
    canonical = img_dir / "seed_0.img"
    if img_files[0] != canonical:
        img_files[0].rename(canonical)
    return canonical


def worker_mutate(
    *, seed_id: str, parent_img: Path, output_dir: Path, arch: Any,
    dive_enable: bool, is_rv32: bool, template_type: str, architecture: str,
) -> Path:
    """Mutate an existing seed.  Returns path to new seed_0.img."""
    import shutil
    from fuzzer.generator.core.mutator import mutate_instructions_parallel
    from fuzzer.utils.elf_to_img import process_file

    # Locate parent .S file (parent_dir is {output_dir}/{parent_id}/)
    parent_dir = parent_img.parent
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

    img_files = list(img_dir.glob("*.img"))
    if not img_files:
        raise RuntimeError(f"No .img file generated in {img_dir}")
    canonical = img_dir / "seed_0.img"
    if img_files[0] != canonical:
        img_files[0].rename(canonical)
    return canonical


def worker_execute(
    *, img_path: Path, seed_id: str, emu_cmd: str, emu_path: str,
) -> dict[str, Any]:
    """Run the emulator on a seed and return execution result dict."""
    observe_rel = f"difftest.observe.{seed_id}.jsonl"
    observe_flag = f" --rvfuzz-observe={observe_rel} --rvfuzz-observe-level=all"

    command = emu_cmd.replace("$1", f'"{img_path}"')
    if "--rvfuzz-observe=" not in command:
        command = command + observe_flag

    start = time.monotonic()
    observe_path = Path(emu_path) / observe_rel
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
            "observation_path": observe_path,
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


def worker_entry(task: WorkerTask) -> WorkerResult:
    """Entry point for ProcessPoolExecutor.  Stateless -- all config in task."""
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
        parent_id = task.seed_ref.lineage_parent or task.seed_ref.seed_id
        parent_img = seed_path(task.output_dir, parent_id)
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
    obs_path = exec_data.get("observation_path")
    if obs_path is not None and obs_path.exists():
        obs = parse_observation(obs_path)
        try:
            obs_path.unlink()
        except OSError:
            pass
    else:
        from fuzzer.core.observation import ObservationData
        obs = ObservationData(transitions=[], diff_families=[])

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
