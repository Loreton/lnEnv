#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-05-2026 15.54.50
#

import sys; sys.dont_write_bytecode = True
import os
import shutil
import zipapp

#-------------
from context import gVars as gv
from run_command import run_command
from create_entry_point import create_entry_point_main

##################################################
# Build functions
##################################################
def build_uv_project(project_info: dict, pyz_file: Path, action: str = None):
    """Build using uv structure"""
    print(">> Building uv-based project")

    # Sync dependencies with uv
    print(">> Syncing dependencies with uv")
    if not run_command(["uv", "sync"], cwd=gv.BASE_DIR):
        print("ERROR: Failed to sync dependencies with uv")
        sys.exit(1)

    # Prepare stage directory
    if gv.STAGE_DIR.exists():
        shutil.rmtree(gv.STAGE_DIR)
    gv.STAGE_DIR.mkdir()

    # Create __main__.py from the entry point defined in pyproject.toml
    create_entry_point_main(project_info, gv.STAGE_DIR / "__main__.py")

    # Copy the entire src directory
    if project_info["src_dir"].exists():
        for item in project_info["src_dir"].iterdir():
            if item.is_dir():
                dest = gv.STAGE_DIR / item.name
                if not dest.exists():
                    shutil.copytree(item, dest)
                    print(f">> Copied package: {item.name}")
            elif item.suffix == '.py':
                shutil.copy2(item, gv.STAGE_DIR / item.name)
                print(f">> Copied: {item.name}")

    # Copy external libraries
    if gv.pyLnLib_SRC and gv.pyLnLib_SRC.exists():
        print(f">> Copying {gv.pyLnLib_name}: {gv.pyLnLib_SRC}")
        shutil.copytree(gv.pyLnLib_SRC, gv.STAGE_DIR / gv.pyLnLib_name)

    # Copy scripts if they exist
    scripts_dir = gv.BASE_DIR / "scripts"
    if scripts_dir.exists():
        print(f">> Copying scripts")
        shutil.copytree(scripts_dir, gv.STAGE_DIR / "scripts")

    # Create .pyz
    gv.DIST_DIR.mkdir(exist_ok=True)
    if pyz_file.exists():
        pyz_file.unlink()

    print(f">> Creating {pyz_file}")
    zipapp.create_archive(
        source=gv.STAGE_DIR,
        target=pyz_file,
        interpreter="/usr/bin/env python3",
        compressed=True
    )

    # Get file size
    size = pyz_file.stat().st_size / 1024
    print(f">> Build completed: {pyz_file} ({size:.1f} KB)")

    # Copy to utils if needed
    if gv.PYZ_TO_UTIL:
        gv.PYZ_TO_UTIL.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(pyz_file, gv.PYZ_TO_UTIL)
        print(f">> Build copied to: {gv.PYZ_TO_UTIL}")
