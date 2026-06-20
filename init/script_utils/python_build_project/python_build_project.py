#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-05-2026 15.52.03
#

import sys; sys.dont_write_bytecode = True
import os
import shutil
import zipapp
import subprocess
import tomllib
from pathlib import Path
from typing import List, Optional, Dict

#-------------
from context import gVars as gv
from build_uv_project import build_uv_project

##################################################
# Utility functions
##################################################
def resolvePath(path: Path) -> Optional[Path]:
    """Resolve path if exists"""
    path = Path(path)
    if path.exists():
        return path.resolve()
    print(f"path: {path} NOT FOUND!")
    return None

def load_pyproject(base_dir: Path) -> Optional[Dict]:
    """Load pyproject.toml"""
    pyproject_path = base_dir / "pyproject.toml"
    if not pyproject_path.exists():
        return None

    with open(pyproject_path, "rb") as f:
        return tomllib.load(f)



def discover_project_structure(base_dir: Path) -> Dict:
    """Discover project structure from pyproject.toml"""

    pyproject = load_pyproject(base_dir)

    if not pyproject:
        # Legacy project
        return {
            "is_uv": False,
            "project_name": base_dir.name,
            "package_name": base_dir.name.replace("-", "_").lower(),
            "src_dir": base_dir / "src",
            "main_file": base_dir / "__main__.py",
            "venv_dir": base_dir / ".venv",
            "entry_point": None,
        }

    # UV project
    project_data = pyproject.get("project", {})
    scripts = project_data.get("scripts", {})

    # Get the first script entry point
    entry_point = None
    if scripts:
        # Prendi il primo script (di solito il nome del progetto)
        first_script = list(scripts.keys())[0]
        entry_point = scripts[first_script]
        print(f">> Found entry point: {first_script} -> {entry_point}")

    package_name = project_data.get("name", base_dir.name).replace("-", "_").lower()

    return {
        "is_uv": True,
        "project_name": project_data.get("name", base_dir.name),
        "package_name": package_name,
        "src_dir": base_dir / "src",
        "venv_dir": base_dir / ".venv",
        "entry_point": entry_point,
        "pyproject": pyproject,
    }


def clean_venv(venv_path: Path):
    """Clean virtual environment from unnecessary files"""
    print(">> Cleaning venv")

    # Remove __pycache__ directories
    for path in venv_path.rglob("__pycache__"):
        shutil.rmtree(path, ignore_errors=True)

    # Remove compiled files
    for path in venv_path.rglob("*.pyc"):
        path.unlink(missing_ok=True)
    for path in venv_path.rglob("*.pyo"):
        path.unlink(missing_ok=True)

    # Remove test directories
    for path in venv_path.rglob("*"):
        if path.is_dir() and path.name in ["tests", "test", "docs", "examples"]:
            shutil.rmtree(path, ignore_errors=True)

def rotate_previous_build(file: Path):
    """Rotate build history"""
    HISTORY_DIR.mkdir(parents=True, exist_ok=True)

    if not file.exists():
        return

    print(">> Rotating build history")

    for i in range(MAX_HISTORY, 1, -1):
        src = HISTORY_DIR / f"{PROJECT_NAME}_v{i-1:02d}.pyz"
        dst = HISTORY_DIR / f"{PROJECT_NAME}_v{i:02d}.pyz"
        if src.exists():
            src.replace(dst)

    latest = HISTORY_DIR / f"{PROJECT_NAME}_v01.pyz"
    file.replace(latest)
    print(f">> Saved previous build as: {latest}")

def clean(stage_area: Path):
    """Clean build stage"""
    if stage_area.exists():
        shutil.rmtree(stage_area)
    print(">> Clean completed")





##################################################
# Main
##################################################
def main():
    # Discover project structure
    project_info = discover_project_structure(gv.BASE_DIR)

    print(f"\n>> Project: {project_info['project_name']}")
    print(f">> Type: {'uv' if project_info['is_uv'] else 'legacy'}")

    if not project_info["is_uv"]:
        # Legacy project checks
        if not gv.MAIN_FILE.exists():
            print(f"ERROR: {gv.MAIN_FILE.name} not found in {gv.BASE_DIR}")
            sys.exit(1)

    if len(sys.argv) == 1:
        sys.argv.append("-h")

    first_arg = sys.argv[1]
    second_arg = sys.argv[2] if len(sys.argv) > 2 else None

    if first_arg == "ziplib":
        gv.LIB_SRC = resolvePath(pyLnLib_SRC)
        if not gv.LIB_SRC:
            gv.LIB_SRC = resolvePath(gv.BASE_DIR / gv.pyLnLib_name)
        if gv.LIB_SRC:
            ZIP_OUTPUT = gv.BASE_DIR / f"{gv.pyLnLib_name}.zip"
            build_lib_zip(basename=gv.pyLnLib_name, sourcePATH=gv.LIB_SRC, zipOutput=ZIP_OUTPUT)
        return

    elif first_arg == "build":
        if project_info["is_uv"]:
            build_uv_project(project_info, gv.PYZ_FILE, second_arg)
        else:
            build_legacy_project(gv.PYZ_FILE, second_arg)

    elif first_arg == "bundle":
        if project_info["is_uv"]:
            build_uv_project(project_info, gv.PYZ_FILE, None)
        else:
            build_legacy_project(gv.PYZ_FILE, None)
        bundle(gv.BUNDLE_DIR / f"{project_info['project_name']}_bundle.tgz", project_info)

    elif first_arg == "clean":
        clean(gv.STAGE_DIR)

    else:
        print(f"""
Usage: python build.py [command]

Commands:
    ziplib      Create zip of {gv.pyLnLib_name}
    build       Build .pyz file [--version to rotate]
    bundle      Create complete bundle (.pyz + venv)
    clean       Clean stage area

For uv projects (created with init_uv_project.sh):
    - Automatically reads entry point from pyproject.toml
    - Supports [project.scripts] section
    - Works with 'uv run' command
        """)


if __name__ == "__main__":
    # Paths configuration
    # SCRIPT_DIR = Path(__file__).resolve().parent
    # gv.BASE_DIR = Path.cwd()
    # PROJECT_NAME = gv.BASE_DIR.name

    # # External libraries
    # pyLnLib_SRC = Path("/home/loreto/filu/Programming/gitREPO/pyLnLib/src/pyLnLib")
    # gv.pyLnLib_name = "pyLnLib"

    # # Build directories
    # DIST_DIR = gv.BASE_DIR / "dist"
    # gv.STAGE_DIR = gv.BASE_DIR / ".build_stage"
    # HISTORY_DIR = DIST_DIR / "history"

    # # Bundle directory
    # gv.BUNDLE_DIR = Path("/home/loreto/filu/Applications/bundles") / PROJECT_NAME
    # gv.BUNDLE_DIR.mkdir(parents=True, exist_ok=True)

    # # Files
    # gv.PYZ_FILE = DIST_DIR / f"{PROJECT_NAME}.pyz"
    # PYZ_TO_UTIL = SCRIPT_DIR / f"{PROJECT_NAME}.pyz"

    # # Legacy project settings (kept for compatibility)
    # gv.MAIN_FILE = gv.BASE_DIR / "__main__.py"
    # INCLUDE_DIRS = ["source", "conf", "modules"]
    # MAX_HISTORY = 10

    main()

