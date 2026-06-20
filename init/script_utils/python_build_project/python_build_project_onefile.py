#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-05-2026 16.08.37
#

import sys; sys.dont_write_bytecode = True
import os
import shutil
import zipapp
import subprocess
import tomllib
from pathlib import Path
from typing import List, Optional, Dict

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

def run_command(cmd: List[str], cwd: Optional[Path] = None, capture: bool = False) -> bool:
    """Run a command and return success status"""
    try:
        if capture:
            result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
            return result.returncode == 0, result.stdout, result.stderr
        else:
            result = subprocess.run(cmd, cwd=cwd)
            return result.returncode == 0
    except Exception as e:
        print(f"Exception running command: {e}")
        return False

def load_pyproject(base_dir: Path) -> Optional[Dict]:
    """Load pyproject.toml"""
    pyproject_path = base_dir / "pyproject.toml"
    if not pyproject_path.exists():
        return None

    with open(pyproject_path, "rb") as f:
        return tomllib.load(f)

##################################################
# Build functions
##################################################
def build_uv_project(project_info: dict, pyz_file: Path, action: str = None):
    """Build using uv structure"""
    print(">> Building uv-based project")

    # Sync dependencies with uv
    print(">> Syncing dependencies with uv")
    if not run_command(["uv", "sync"], cwd=BASE_DIR):
        print("ERROR: Failed to sync dependencies with uv")
        sys.exit(1)

    # Prepare stage directory
    if STAGE_DIR.exists():
        shutil.rmtree(STAGE_DIR)
    STAGE_DIR.mkdir()

    # Create __main__.py from the entry point defined in pyproject.toml
    create_entry_point_main(project_info, STAGE_DIR / "__main__.py")

    # Copy the entire src directory
    if project_info["src_dir"].exists():
        for item in project_info["src_dir"].iterdir():
            if item.is_dir():
                dest = STAGE_DIR / item.name
                if not dest.exists():
                    shutil.copytree(item, dest)
                    print(f">> Copied package: {item.name}")
            elif item.suffix == '.py':
                shutil.copy2(item, STAGE_DIR / item.name)
                print(f">> Copied: {item.name}")

    # Copy external libraries
    if pyLnLib_SRC and pyLnLib_SRC.exists():
        print(f">> Copying {pyLnLib_name}: {pyLnLib_SRC}")
        shutil.copytree(pyLnLib_SRC, STAGE_DIR / pyLnLib_name)

    # Copy scripts if they exist
    scripts_dir = BASE_DIR / "scripts"
    if scripts_dir.exists():
        print(f">> Copying scripts")
        shutil.copytree(scripts_dir, STAGE_DIR / "scripts")

    # Create .pyz
    DIST_DIR.mkdir(exist_ok=True)
    if pyz_file.exists():
        pyz_file.unlink()

    print(f">> Creating {pyz_file}")
    zipapp.create_archive(
        source=STAGE_DIR,
        target=pyz_file,
        interpreter="/usr/bin/env python3",
        compressed=True
    )

    # Get file size
    size = pyz_file.stat().st_size / 1024
    print(f">> Build completed: {pyz_file} ({size:.1f} KB)")

    # Copy to utils if needed
    if PYZ_TO_UTIL:
        PYZ_TO_UTIL.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(pyz_file, PYZ_TO_UTIL)
        print(f">> Build copied to: {PYZ_TO_UTIL}")

def create_entry_point_main(project_info: dict, wrapper_path: Path):
    """Create __main__.py from the project's entry point"""

    # Get entry point from pyproject.toml
    entry_point = project_info.get("entry_point")
    package_name = project_info["package_name"]

    if entry_point:
        # Parse "package.module:function"
        if ":" in entry_point:
            module_path, function_name = entry_point.split(":")
        else:
            module_path = entry_point
            function_name = "main"

        # Convert to import path
        import_path = module_path.replace("/", ".")

        wrapper_content = f'''#!/usr/bin/env python3
"""Auto-generated __main__ for {project_info["project_name"]}

Entry point: {entry_point}
"""

import sys
import os

# Add current directory to path
sys.path.insert(0, os.path.dirname(__file__))

try:
    # Import the main function from the specified module
    module_path = "{import_path}"
    function_name = "{function_name}"

    # Dynamically import
    module = __import__(module_path, fromlist=[function_name])
    main_func = getattr(module, function_name)

except ImportError as e:
    print(f"ERROR: Could not import {{module_path}}")
    print(f"Details: {{e}}")
    print("\\nAvailable packages:")
    for item in os.listdir(os.path.dirname(__file__)):
        if item != "__pycache__" and not item.startswith("."):
            print(f"  - {{item}}")
    sys.exit(1)
except AttributeError as e:
    print(f"ERROR: Could not find function '{{function_name}}' in {{module_path}}")
    print(f"Details: {{e}}")
    sys.exit(1)

if __name__ == "__main__":
    sys.exit(main_func())
'''
    else:
        # Fallback: cerca main.py nel package
        wrapper_content = f'''#!/usr/bin/env python3
"""Auto-generated __main__ for {project_info["project_name"]}"""

import sys
import os

# Add current directory to path
sys.path.insert(0, os.path.dirname(__file__))

def find_main():
    """Cerca la funzione main nel package"""
    try:
        # Prova a importare dal package principale
        package_name = "{package_name}"
        main_module = __import__(f"{{package_name}}.main", fromlist=["main"])
        if hasattr(main_module, "main"):
            return main_module.main
    except ImportError:
        pass

    # Cerca in tutti i moduli
    for item in os.listdir(os.path.dirname(__file__)):
        if item.endswith(".py") and item != "__main__.py":
            module_name = item[:-3]
            try:
                module = __import__(module_name)
                if hasattr(module, "main"):
                    return module.main
            except ImportError:
                pass

    return None

if __name__ == "__main__":
    main_func = find_main()
    if main_func:
        sys.exit(main_func())
    else:
        print(f"ERROR: Could not find main function in {package_name}")
        sys.exit(1)
'''

    wrapper_path.write_text(wrapper_content)
    print(f">> Created entry point: {entry_point if entry_point else 'auto-detected'}")

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

def build_lib_zip(basename: str, sourcePATH: Path, zipOutput: Path):
    """Create zip of library"""
    import zipfile
    print("\t>> Building library zip")

    if not sourcePATH.exists():
        raise FileNotFoundError(f"Library not found: {sourcePATH}")

    if zipOutput.exists():
        zipOutput.unlink()

    with zipfile.ZipFile(zipOutput, "w", zipfile.ZIP_DEFLATED) as zf:
        for file in sourcePATH.rglob("*"):
            if file.is_file():
                rel_path = file.relative_to(sourcePATH).__str__()
                if rel_path.startswith('.'):
                    continue
                arcname = Path(basename) / rel_path
                print(f"\t\tadding: {arcname}")
                zf.write(file, arcname)

    print(f"\t>> Created: {zipOutput}\n")

##################################################
# Main
##################################################
def main():
    # Discover project structure
    project_info = discover_project_structure(BASE_DIR)

    print(f"\n>> Project: {project_info['project_name']}")
    print(f">> Type: {'uv' if project_info['is_uv'] else 'legacy'}")

    if not project_info["is_uv"]:
        # Legacy project checks
        if not MAIN_FILE.exists():
            print(f"ERROR: {MAIN_FILE.name} not found in {BASE_DIR}")
            sys.exit(1)

    if len(sys.argv) == 1:
        sys.argv.append("-h")

    first_arg = sys.argv[1]
    second_arg = sys.argv[2] if len(sys.argv) > 2 else None

    if first_arg == "ziplib":
        LIB_SRC = resolvePath(pyLnLib_SRC)
        if not LIB_SRC:
            LIB_SRC = resolvePath(BASE_DIR / pyLnLib_name)
        if LIB_SRC:
            ZIP_OUTPUT = BASE_DIR / f"{pyLnLib_name}.zip"
            build_lib_zip(basename=pyLnLib_name, sourcePATH=LIB_SRC, zipOutput=ZIP_OUTPUT)
        return

    elif first_arg == "build":
        if project_info["is_uv"]:
            build_uv_project(project_info, PYZ_FILE, second_arg)
        else:
            build_legacy_project(PYZ_FILE, second_arg)

    elif first_arg == "bundle":
        if project_info["is_uv"]:
            build_uv_project(project_info, PYZ_FILE, None)
        else:
            build_legacy_project(PYZ_FILE, None)
        bundle(BUNDLE_DIR / f"{project_info['project_name']}_bundle.tgz", project_info)

    elif first_arg == "clean":
        clean(STAGE_DIR)

    else:
        print(f"""
Usage: python build.py [command]

Commands:
    ziplib      Create zip of {pyLnLib_name}
    build       Build .pyz file [--version to rotate]
    bundle      Create complete bundle (.pyz + venv)
    clean       Clean stage area

For uv projects (created with init_uv_project.sh):
    - Automatically reads entry point from pyproject.toml
    - Supports [project.scripts] section
    - Works with 'uv run' command
        """)

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

if __name__ == "__main__":
    # Paths configuration
    SCRIPT_DIR = Path(__file__).resolve().parent
    BASE_DIR = Path.cwd()
    PROJECT_NAME = BASE_DIR.name

    # External libraries
    pyLnLib_SRC = Path("/home/loreto/filu/Programming/gitREPO/pyLnLib/src/pyLnLib")
    pyLnLib_name = "pyLnLib"

    # Build directories
    DIST_DIR = BASE_DIR / "dist"
    STAGE_DIR = BASE_DIR / ".build_stage"
    HISTORY_DIR = DIST_DIR / "history"

    # Bundle directory
    BUNDLE_DIR = Path("/home/loreto/filu/Applications/bundles") / PROJECT_NAME
    BUNDLE_DIR.mkdir(parents=True, exist_ok=True)

    # Files
    PYZ_FILE = DIST_DIR / f"{PROJECT_NAME}.pyz"
    PYZ_TO_UTIL = SCRIPT_DIR / f"{PROJECT_NAME}.pyz"

    # Legacy project settings (kept for compatibility)
    MAIN_FILE = BASE_DIR / "__main__.py"
    INCLUDE_DIRS = ["source", "conf", "modules"]
    MAX_HISTORY = 10

    main()