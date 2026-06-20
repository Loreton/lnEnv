#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 01-05-2026 18.39.29
#

import sys; sys.dont_write_bytecode = True
import os

import shutil
import zipapp
from pathlib import Path



### - legge la current dir
SCRIPT_DIR = Path(__file__).resolve().parent

### - legge la current dir
BASE_DIR     = Path.cwd()
### - preleva nome della dir
PROJECT_NAME = BASE_DIR.name

### - file che deve esistere altrimenti ignoriamo il launch
MAIN_FILE    = BASE_DIR / "__main__.py"

MODULES_DIR  = BASE_DIR / "modules"
LIB_SRC      = (BASE_DIR / "../../pyLnLib").resolve()
DIST_DIR     = BASE_DIR / "dist"
HISTORY_DIR  = DIST_DIR / "history"
STAGE_DIR    = BASE_DIR / ".build_stage"
ZIP_LIB      = BASE_DIR / "pyLnLib.zip"

### - file contente il progetto
PYZ_FILE     = DIST_DIR / f"{PROJECT_NAME}.pyz"
PYZ_TO_UTIL  = SCRIPT_DIR / f"{PROJECT_NAME}.pyz"

### - numero max di backups
MAX_HISTORY  = 10


##################################################
# -
##################################################
def check_project():
    if not MAIN_FILE.exists():
        print(f"ERROR: {MAIN_FILE.name} not found in {BASE_DIR}")
        print("This launcher can run only Python projects with __main__.py")
        sys.exit(1)



##################################################
# -
##################################################
def build_lib_zip():
    import zipfile
    print("\t>> Building pyLnLib.zip")

    if not LIB_SRC.exists():
        raise FileNotFoundError(f"Library not found: {LIB_SRC}")

    if ZIP_LIB.exists():
        ZIP_LIB.unlink()

    with zipfile.ZipFile(ZIP_LIB, "w", zipfile.ZIP_DEFLATED) as zf:
        for file in LIB_SRC.rglob("*"):
            if file.is_file():
                arcname = Path("pyLnLib") / file.relative_to(LIB_SRC)
                print(f"\t\tadding: {file}")
                zf.write(file, arcname)

    print(f"\t>> Created: {ZIP_LIB}\n")


##################################################
# -
##################################################
def prepare_stage():
    if STAGE_DIR.exists():
        shutil.rmtree(STAGE_DIR)

    STAGE_DIR.mkdir()

    shutil.copy2(MAIN_FILE, STAGE_DIR / "__main__.py")

    if MODULES_DIR.exists():
        shutil.copytree(MODULES_DIR, STAGE_DIR / "modules")

    if LIB_SRC.exists():
        shutil.copytree(LIB_SRC, STAGE_DIR / "pyLnLib")


##################################################
# -
##################################################
def run_dev(args=None):
    import subprocess
    args = args or []
    subprocess.run([sys.executable, str(MAIN_FILE), *args], check=True )




##################################################
# - fa lo shift delle versioni
# - v01 = ultima build precedente
# - v02 = penultima
# - v03 = più vecchia
# - ...
# - v10
##################################################
def rotate_previous_build():
    HISTORY_DIR.mkdir(parents=True, exist_ok=True)

    if not PYZ_FILE.exists():
        return

    print(">> Rotating build history")

    # shift v09 -> v10 ... v01 -> v02
    for i in range(MAX_HISTORY, 1, -1):
        src = HISTORY_DIR / f"{PROJECT_NAME}_v{i-1:02d}.pyz"
        dst = HISTORY_DIR / f"{PROJECT_NAME}_v{i:02d}.pyz"

        if src.exists():
            src.replace(dst)

    # current -> v01
    latest = HISTORY_DIR / f"{PROJECT_NAME}_v01.pyz"
    '''
        The pathlib.replace() method is a versatile tool for renaming and moving files and directories.
        It simplifies file management tasks in Python.
        replace() is similar to rename(), but with a key difference.
        rename() raises an error if the target exists, while replace() overwrites it.
    '''
    PYZ_FILE.replace(latest)
    print(f">> Saved previous build as: {latest}")



##################################################
# -
##################################################
def build():
    print(">> Preparing build stage")

    rotate_previous_build()

    prepare_stage()

    DIST_DIR.mkdir(exist_ok=True)

    if PYZ_FILE.exists():
        PYZ_FILE.unlink()

    print(">> Creating .pyz")
    zipapp.create_archive(
        source=STAGE_DIR,
        target=PYZ_FILE,
        interpreter="/usr/bin/env python3"
    )

    print(f">> Build completed: {PYZ_FILE}")

    ### - copy zipFile to utils_directory
    shutil.copy2(PYZ_FILE, PYZ_TO_UTIL)
    print(f">> Build copied to: {PYZ_TO_UTIL}")



##################################################
# -
##################################################
def clean():
    if STAGE_DIR.exists():
        shutil.rmtree(STAGE_DIR)

    print(">> Clean completed")




#############################################################
# args:
#    None:  help of run.py
#    run:   run program
#    build: crea un .pyz self-contained
#    ziplib: crea lnPyLib.zip
#    other: args for program
#############################################################
def main():
    check_project()
    launcher_commands = {
        "build": build,
        "clean": clean,
        "ziplib": build_lib_zip,
    }

    # nessun parametro -> run normale
    if len(sys.argv) == 1:
        run_dev([])
        return

    first_arg = sys.argv[1]

    # comando del launcher
    if first_arg in launcher_commands:
        launcher_commands[first_arg]()
        return

    # qualsiasi altra cosa -> passa al main program
    run_dev(sys.argv[1:])


'''
    dist/
    ├── git_commit.pyz
    └── history/
        ├── git_commit_v01.pyz
        ├── git_commit_v02.pyz
        ├── ...
        └── git_commit_v10.pyz
'''

if __name__ == "__main__":
    main()