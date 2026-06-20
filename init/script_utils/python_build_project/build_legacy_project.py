#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-05-2026 15.38.59
#

import sys; sys.dont_write_bytecode = True
import os
import shutil
import zipapp

from pathlib import Path



def build_legacy_project(pyz_file: Path, action: str = None):
    """Build legacy project (without pyproject.toml)"""
    print(">> Building legacy project")

    if action == '--version':
        rotate_previous_build(file=pyz_file)

    if STAGE_DIR.exists():
        shutil.rmtree(STAGE_DIR)
    STAGE_DIR.mkdir()

    if MAIN_FILE.exists():
        shutil.copy2(MAIN_FILE, STAGE_DIR / "__main__.py")

    if pyLnLib_SRC.exists():
        print(f">> Copying {pyLnLib_name}: {pyLnLib_SRC}")
        shutil.copytree(pyLnLib_SRC, STAGE_DIR / pyLnLib_name)

    for dir_name in INCLUDE_DIRS:
        DIR = resolvePath(BASE_DIR / dir_name)
        if DIR and DIR.exists():
            print(f"copying {DIR}")
            shutil.copytree(DIR, STAGE_DIR / dir_name)

    DIST_DIR.mkdir(exist_ok=True)

    if pyz_file.exists():
        pyz_file.unlink()

    print(f">> Creating {pyz_file}")
    zipapp.create_archive(
        source=STAGE_DIR,
        target=pyz_file,
        interpreter="/usr/bin/env python3"
    )

    print(f">> Build completed: {pyz_file}")

    if PYZ_TO_UTIL:
        PYZ_TO_UTIL.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(pyz_file, PYZ_TO_UTIL)
        print(f">> Build copied to: {PYZ_TO_UTIL}")
