# Copyright (c) 2024-2025 Institute of Information Engineering, Chinese Academy of Sciences
# 
# DiveFuzz is licensed under Mulan PSL v2.
# You can use this software according to the terms and conditions of the Mulan PSL v2.
# You may obtain a copy of Mulan PSL v2 at:
#          http://license.coscl.org.cn/MulanPSL2
# 
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# 
# See the Mulan PSL v2 for more details.


import os
from pathlib import Path
import subprocess
from fuzzer.config.dut_config import GeneratedSeedConfig

from fuzzer.config.divefuzz_config import DiveFuzzArgConfig
from fuzzer.generator.core.mutator import mutate_instructions_parallel
from fuzzer.utils.elf_to_img import process_assembly_files
from fuzzer.generator.core.generator import generate_instructions_parallel
from fuzzer.generator.config.config_manager import setup_config

# Module-level variable to store the Config object
_divefuzz_config = None


def setup_divefuzz(seed_config: GeneratedSeedConfig, global_logger):
    global _divefuzz_config
    # make sure `riscv64-unknown-elf-as`, `riscv64-unknown-elf-gcc`,
    # `riscv64-unknown-elf-ld` and `riscv64-unknown-elf-objcopy` are specified in the environment
    riscv_toolchain = [
        'riscv64-unknown-elf-as', 'riscv64-unknown-elf-gcc', 'riscv64-unknown-elf-ld', 'riscv64-unknown-elf-objcopy'
    ]
    for tool in riscv_toolchain:
        try:
            subprocess.run([tool, '--version'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except FileNotFoundError:
            raise Exception(f"{tool} not found in environment, DiveFuzz will not work.")
    
    # fetch `spike` path
    if 'spike' not in os.environ:
        global_logger.warning("spike not found in environment")
    else:
        spike_path = os.environ['spike']
        
        # check `spike` path contain `DiveFuzz`
        if 'DiveFuzz' not in spike_path:
            global_logger.warning("Your spike path does not contain `DiveFuzz`. Diversity function will not work.")
     
    divefuzz_config = DiveFuzzArgConfig(
        mutation=seed_config.divefuzz.mode == "mutate",
        generate=seed_config.divefuzz.mode == "generate",
        eliminate_enable=seed_config.divefuzz.dive_enable,
        cva6=seed_config.divefuzz.is_cva6,
        rv32=seed_config.divefuzz.is_rv32,
        instr_number=seed_config.divefuzz.ins_num,
        seeds=seed_config.divefuzz.seeds_num,
        max_workers=seed_config.divefuzz.threads,
        seed_dir=Path(seed_config.divefuzz.seeds_output),
        mutate_out=Path(seed_config.divefuzz.mutate_input) if seed_config.divefuzz.mutate_input else Path.cwd(),
        out_dir=Path(seed_config.divefuzz.seeds_output),
        enable_ext=seed_config.divefuzz.enable_extension,
        exclude_ext=seed_config.divefuzz.exclude_extension if seed_config.divefuzz.exclude_extension else [],
        template_type=seed_config.divefuzz.template_type,
        allowed_ext_name=seed_config.divefuzz.allowed_ext_name,
        architecture=seed_config.divefuzz.architecture,
    )
    _divefuzz_config = setup_config(divefuzz_config)


def run_divefuzz(seed_config: GeneratedSeedConfig, seed_config_logger) -> list:
    global _divefuzz_config
    assert(_divefuzz_config is not None)
    # handle generate
    if seed_config.divefuzz.mode == "generate":
        generate_instructions_parallel(
            instr_number=seed_config.divefuzz.ins_num,
            seed_times=seed_config.divefuzz.seeds_num,
            eliminate_enable=seed_config.divefuzz.dive_enable,
            is_rv32=seed_config.divefuzz.is_rv32,
            max_workers=seed_config.divefuzz.threads,
            arch=_divefuzz_config.arch,
            template_type=seed_config.divefuzz.template_type,
            out_dir=str(_divefuzz_config.out_dir),
            architecture=_divefuzz_config.architecture
        )

    elif seed_config.divefuzz.mode == "mutate":
        mutate_instructions_parallel(
            directory_path=Path(seed_config.divefuzz.mutate_input) if seed_config.divefuzz.mutate_input else Path.cwd(),
            mutate_directory=Path(seed_config.divefuzz.seeds_output),
            max_workers=seed_config.divefuzz.threads,
            enable_ext=seed_config.divefuzz.enable_extension,
            exclude_extensions=seed_config.divefuzz.exclude_extension if seed_config.divefuzz.exclude_extension else [],
            eliminate_enable=seed_config.divefuzz.dive_enable,
            arch=_divefuzz_config.arch,
            template_type=seed_config.divefuzz.template_type
        )
    else:
        raise ValueError(f"Unknown mode: {seed_config.divefuzz.mode}")

    return process_divefuzz_asm(seed_config, seed_config_logger)


def run_divefuzz_single(out_dir: str, instr_number: int = 200,
                        template_type: str = "rocket",
                        architecture: str = "rkt",
                        eliminate_enable: bool = True,
                        is_rv32: bool = False,
                        seed_index: int = 0) -> list:
    """Generate a single seed and return the list of .img file paths.

    Uses the globally-configured _divefuzz_config (set by setup_divefuzz).
    Each call writes to a unique subdirectory (iter_{seed_index}) to avoid
    overwriting seeds from other iterations.
    """
    global _divefuzz_config
    if _divefuzz_config is None:
        raise RuntimeError("setup_divefuzz() must be called before run_divefuzz_single()")

    # Resolve to absolute path so the generated .img paths are valid
    # regardless of the emulator's working directory.
    from pathlib import Path as _Path
    base_dir = _Path(out_dir).resolve()
    generator_output_dir = base_dir / f"iter_{seed_index:06d}"

    generate_instructions_parallel(
        instr_number=instr_number,
        seed_times=1,
        eliminate_enable=eliminate_enable,
        is_rv32=is_rv32,
        max_workers=1,
        arch=_divefuzz_config.arch,
        template_type=template_type,
        out_dir=str(generator_output_dir),
        architecture=architecture,
    )

    # Convert .S -> .elf -> .img
    process_assembly_files(str(generator_output_dir))

    img_dir = generator_output_dir / 'img_file'
    if not img_dir.exists():
        return []

    seed_files = []
    for file in os.listdir(img_dir):
        if file.endswith(".img"):
            seed_files.append(os.path.join(img_dir, file))

    return seed_files
        


def run_divefuzz_mutate(seed_path: str, out_dir: str,
                        eliminate_enable: bool = True,
                        is_rv32: bool = False,
                        architecture: str = "rkt",
                        template_type: str = "rocket") -> list:
    """Mutate an existing seed and return the list of mutated .img file paths.

    Locates the .S assembly file corresponding to the given .img seed,
    runs DiveFuzz instruction-level mutation, and returns the resulting
    .img files.
    """
    global _divefuzz_config
    if _divefuzz_config is None:
        raise RuntimeError("setup_divefuzz() must be called before run_divefuzz_mutate()")

    from pathlib import Path as _Path
    import shutil

    img_path = _Path(seed_path).resolve()
    if not img_path.exists():
        return []

    # Locate the .S assembly file: img_file/seed_0.img → asm_file/seed_0.S
    img_dir = img_path.parent
    asm_dir = img_dir.parent / "asm_file"
    asm_name = img_path.stem + ".S"
    asm_path = asm_dir / asm_name
    if not asm_path.exists():
        # Fallback: search recursively
        asm_path = None
        for f in img_dir.parent.rglob("*.S"):
            if f.stem == img_path.stem:
                asm_path = f
                break
        if asm_path is None:
            return []

    # Set up mutation workspace
    mutate_workspace = _Path(out_dir).resolve() / "mutate_work" / img_path.stem
    mutate_input = mutate_workspace / "input"
    mutate_output = mutate_workspace / "output"
    mutate_input.mkdir(parents=True, exist_ok=True)
    mutate_output.mkdir(parents=True, exist_ok=True)

    # Copy .S file to mutation input directory
    shutil.copy2(str(asm_path), str(mutate_input / asm_name))

    # Run mutation
    from generator.core.mutator import mutate_instructions_parallel
    mutate_instructions_parallel(
        directory_path=mutate_input,
        mutate_directory=mutate_output,
        max_workers=1,
        enable_ext=False,
        exclude_extensions=[],
        eliminate_enable=eliminate_enable,
        arch=_divefuzz_config.arch,
        template_type=template_type,
    )

    # Convert .S → .img
    process_assembly_files(str(mutate_output))

    # Collect mutated .img files
    img_output_dir = mutate_output / "img_file"
    if not img_output_dir.exists():
        return []

    seed_files = []
    for file in os.listdir(img_output_dir):
        if file.endswith(".img"):
            seed_files.append(os.path.join(img_output_dir, file))

    return seed_files


def process_divefuzz_asm(seed_config: GeneratedSeedConfig, seed_config_logger):

    # Use the configured seeds_output directory
    generator_output_dir = Path(seed_config.divefuzz.seeds_output)

    # convert img/elf
    seed_config_logger.info("Converting assembly to elf files...")
    process_assembly_files(str(generator_output_dir))

    # find img files (binary format for DUT execution)
    # All DUTs (NutShell, Rocket, XiangShan) use .img format
    img_dir = generator_output_dir / 'img_file'
    if not img_dir.exists():
        seed_config_logger.error(f"IMG directory not found: {img_dir}")
        return []

    seed_files = []
    for file in os.listdir(img_dir):
        if file.endswith(".img"):
            seed_files.append(os.path.join(img_dir, file))

    seed_config_logger.info(
        f"Found {len(seed_files)} generated seed files (.img)")

    return seed_files
