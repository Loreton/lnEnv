#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-05-2026 15.40.57
#

import sys; sys.dont_write_bytecode = True
import os



##################################################
# Bundle functions
##################################################
def bundle(tar_file: Path, project_info: dict):
    """Create a bundle with .pyz and venv"""
    import tarfile

    print(">> Building bundle")

    # Ensure .pyz exists
    if not PYZ_FILE.exists():
        print("ERROR: .pyz not found, run build first")
        return

    venv_dir = project_info["venv_dir"]
    if not venv_dir.exists():
        print(f"ERROR: venv not found at {venv_dir}")
        print("Run 'uv sync' first to create virtual environment")
        return

    # Prepare bundle stage
    bundle_stage = DIST_DIR / ".bundle_stage"
    if bundle_stage.exists():
        shutil.rmtree(bundle_stage)
    bundle_stage.mkdir(parents=True)

    # Copy configuration
    conf_dirs = ["conf", "config"]
    for conf_dir in conf_dirs:
        src_conf = BASE_DIR / conf_dir
        if src_conf.exists():
            print(f">> Copying config: {src_conf}")
            shutil.copytree(src_conf, bundle_stage / conf_dir)

    # Copy .pyz
    shutil.copy2(PYZ_FILE, bundle_stage / PYZ_FILE.name)

    # Copy and clean venv
    print(f">> Copying venv: {venv_dir}")
    shutil.copytree(venv_dir, bundle_stage / "venv", symlinks=True)
    clean_venv(bundle_stage / "venv")

    # Create run script
    run_sh = BUNDLE_DIR / "run.sh"
    run_sh_content = f'''#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$DIR/venv/bin/python" "$DIR/{PYZ_FILE.name}" "$@"
'''
    run_sh.write_text(run_sh_content)
    run_sh.chmod(0o755)

    # Create tar.gz
    print(f">> Creating {tar_file}")
    if tar_file.exists():
        tar_file.unlink()

    with tarfile.open(tar_file, "w:gz") as tar:
        tar.add(bundle_stage, arcname=project_info["project_name"])

    # Cleanup
    shutil.rmtree(bundle_stage)

    print(f">> Bundle created: {tar_file}")
    print(f">> Run script created: {run_sh}")
