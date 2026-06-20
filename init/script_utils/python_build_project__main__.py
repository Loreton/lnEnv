#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 22-05-2026 16.53.36
#

import sys; sys.dont_write_bytecode = True
import os

import shutil
import zipapp
from pathlib import Path, PosixPath




##################################################
# -
##################################################
def resolvePath(path: PosixPath):
    path = Path(path)
    if path.exists():
        return path.resolve()
    print(f"path: {path} NOT FOUND!")
    return None



##################################################
# - in teoria non serve
##################################################
def build_lib_zip(basename: str, sourcePATH: str, zipOutput: str):
    import zipfile
    print("\t>> Building pyLnLib.zip")

    if not sourcePATH.exists():
        raise FileNotFoundError(f"Library not found: {sourcePATH}")

    if zipOutput.exists():
        zipOutput.unlink()

    with zipfile.ZipFile(zipOutput, "w", zipfile.ZIP_DEFLATED) as zf:
        for file in sourcePATH.rglob("*"):
            if file.is_file():
                rel_path = file.relative_to(sourcePATH).__str__()
                if rel_path.startswith('.'): continue
                arcname = Path(basename) / rel_path
                print(f"\t\tadding: {arcname}")
                zf.write(file, arcname)

    print(f"\t>> Created: {zipOutput}\n")



##################################################
# -
##################################################
def check_project():

    # if not SRC_DIR.exists():
    #     print(f"ERROR: {SRC_DIR.name} not found in {BASE_DIR}")
    #     print("we'll try to check for __main__.py")
    if not MAIN_FILE.exists():
        print(f"ERROR: {MAIN_FILE.name} not found in {BASE_DIR}")
        print("This launcher can run only Python projects with __main__.py or wir src directory")
        sys.exit(1)

##################################################
# -
##################################################
def prepare_stage():
    if STAGE_DIR.exists():
        shutil.rmtree(STAGE_DIR)

    STAGE_DIR.mkdir()

    shutil.copy2(MAIN_FILE, STAGE_DIR / "__main__.py")

    # copia pyLnLib esterna (se esiste)
    if pyLnLib_SRC.exists():
        print(f">> Copying {pyLnLib_name}: {pyLnLib_SRC}")
        shutil.copytree(pyLnLib_SRC, STAGE_DIR / pyLnLib_name)
    else:
        print(f"ERROR:  {pyLnLib_name} not found: {pyLnLib_SRC}")


    for dir_name in INCLUDE_DIRS:
        DIR = resolvePath(BASE_DIR / dir_name)
        if DIR and DIR.exists():
            print(f"copying {DIR}")
            shutil.copytree(DIR, STAGE_DIR / dir_name)




##################################################
# - fa lo shift delle versioni
# - v01 = ultima build precedente
# - v02 = penultima
# - v03 = più vecchia
# - ...
# - v10
##################################################
def rotate_previous_build(file: str):
    HISTORY_DIR.mkdir(parents=True, exist_ok=True)

    if not file.exists():
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
    file.replace(latest)
    print(f">> Saved previous build as: {latest}")


##################################################
# -
##################################################
def clean(stage_area: str):
    if stage_area.exists():
        shutil.rmtree(stage_area)

    print(">> Clean completed")



##################################################
# -
##################################################
def build(pyz_file: str, action: str=None):

    print(">> Preparing build stage")

    if action == '--version':
        rotate_previous_build(file=pyz_file)

    prepare_stage()

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


    ### - copy zipFile to utils_directory
    shutil.copy2(pyz_file, PYZ_TO_UTIL)
    print(f">> Build copied to: {PYZ_TO_UTIL}")





def clean_venv(venv_path: Path):
    print(">> Cleaning venv")

    patterns_to_remove = [
        "__pycache__",
        "*.pyc",
        "*.pyo",
        "tests",
        "test",
        "*.dist-info",
        "*.egg-info",
    ]

    for path in venv_path.rglob("*"):
        # rimuove cache python
        if path.name == "__pycache__":
            shutil.rmtree(path, ignore_errors=True)

        # rimuove file compilati
        elif path.suffix in [".pyc", ".pyo"]:
            path.unlink(missing_ok=True)

    # opzionale: rimuovere metadata pesanti
    for meta in venv_path.rglob("*.dist-info"):
        shutil.rmtree(meta, ignore_errors=True)

    for meta in venv_path.rglob("*.egg-info"):
        shutil.rmtree(meta, ignore_errors=True)

    for pkg in (venv_path / "lib").rglob("*"):
        if pkg.name in ["tests", "test", "docs", "examples"]:
            shutil.rmtree(pkg, ignore_errors=True)

##################################################
# -
##################################################
def bundle(tar_file: Path, venv_dir: Path = None):
    import tarfile

    print(">> Building bundle")

    # default paths
    # tar_file = tar_file or (DIST_DIR / f"{PROJECT_NAME}_bundle.tgz")
    venv_dir = venv_dir or (BASE_DIR / ".venv")

    if not PYZ_FILE.exists():
        print("ERROR: .pyz not found, run build first")
        return

    if not venv_dir.exists():
        print(f"ERROR: venv not found: {venv_dir}")
        return

    # staging area per bundle
    bundle_stage = DIST_DIR / ".bundle_stage"
    if bundle_stage.exists():
        shutil.rmtree(bundle_stage)
    bundle_stage.mkdir(parents=True)


    # copia config esterna (se esiste)
    CONF_DIR = BASE_DIR / "conf"
    if CONF_DIR.exists():
        print(f">> Copying config: {CONF_DIR}")
        shutil.copytree(CONF_DIR, bundle_stage / "conf")

    # copia pyLnLib esterna (se esiste)
    if pyLnLib_SRC.exists():
        print(f">> Copying {pyLnLib_name}: {pyLnLib_SRC}")
        shutil.copytree(pyLnLib_SRC, bundle_stage / pyLnLib_name)


    # copia pyz
    shutil.copy2(PYZ_FILE, bundle_stage / PYZ_FILE.name)

    # copia venv
    print(f">> Copying venv: {venv_dir}")
    shutil.copytree(venv_dir, bundle_stage / "venv", symlinks=True)

    # pulizia
    clean_venv(bundle_stage / "venv")

    # crea run.sh
    run_sh = BUNDLE_DIR / "run.sh"

    run_sh.write_text(f"""#!/bin/bash
    DIR="$(cd "$(dirname "$0")" && pwd)"

    CONFIG_FILE="$DIR/{PROJECT_NAME}_config.yaml"

    "$DIR/venv/bin/python" \
        "$DIR/{PYZ_FILE.name}" \
        --config-file "$CONFIG_FILE" \
        "$@"
    """)
#     run_sh.write_text(f"""#!/bin/bash
# DIR="$(cd "$(dirname "$0")" && pwd)"
# "$DIR/venv/bin/python" "$DIR/{PYZ_FILE.name}" "--config-file '@{PROJECT_NAME}_config.yaml' "$@"
# """)
    run_sh.chmod(0o755)



    # crea tar.gz
    print(f">> Creating {tar_file}")
    if tar_file.exists():
        tar_file.unlink()

    with tarfile.open(tar_file, "w:gz") as tar:
        tar.add(bundle_stage, arcname=PROJECT_NAME)

    # cleanup
    shutil.rmtree(bundle_stage)

    print(f">> Bundle created: {tar_file}")
    print(f">> script has been created: {run_sh}")



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

    # nessun parametro -> run normale
    if len(sys.argv) == 1:
        sys.argv.append("-h")

    first_arg = sys.argv[1]
    second_arg = sys.argv[2] if len(sys.argv) > 2 else None

    # comando del launcher
    if first_arg == "ziplib":
        LIB_SRC  = resolvePath(pyLnLib_SRC)
        if not LIB_SRC:
            LIB_SRC     = resolvePath(BASE_DIR / pyLnLib_name)

        ZIP_OUTPUT  = BASE_DIR / f"{pyLnLib_name}.zip"
        build_lib_zip(basename=pyLnLib_name, sourcePATH=LIB_SRC, zipOutput=ZIP_OUTPUT)
        return


    elif first_arg == "build":
        build(pyz_file=PYZ_FILE, action=second_arg)

    elif first_arg == "bundle":
        build(pyz_file=PYZ_FILE, action=second_arg)
        bundle(tar_file=(BUNDLE_DIR / f"{PROJECT_NAME}_bundle.tgz"))

    elif first_arg == "clean":
        clean(stage_area=STAGE_DIR)

    else:
        print(f"""
        Please enter one of the folloqinf arguments:
        - ziplib    [zip of {pyLnLib_name}]
        - build     [--version]   [create {PYZ_FILE}]
        - bundle    [create (.pyz + venv).tgz ] (tar -czvf /tmp/aaa.tgz dist/lnSync.pyz .venv/*)
        - clean     [clean stage area]
            """)
        return
'''
    -- build project.pyz
    dist/
    ├── project_name.pyz
    └── history/
        ├── project_name_v01.pyz
        ├── project_name_v02.pyz
        ├── ...
        └── project_name_v10.pyz

    -- project_bundle.tgz
    ├── project_name.pyz
    ├── venv/
    └── run.sh

'''

if __name__ == "__main__":
    ### - legge la script dir
    SCRIPT_DIR = Path(__file__).resolve().parent

    ### - legge la current dir
    BASE_DIR     = Path.cwd()

    ### - preleva nome della dir
    PROJECT_NAME = BASE_DIR.name

    pyLnLib_SRC = Path("/home/loreto/filu/Programming/gitREPO/pyLnLib/src/pyLnLib") ### doppop pyLnLib
    pyLnLib_name  = "pyLnLib"


    DIST_DIR     = BASE_DIR / "dist"
    STAGE_DIR    = BASE_DIR / ".build_stage"
    HISTORY_DIR  = DIST_DIR / "history"

    ### dove trovero il bunlde completo di run_sh.sh
    BUNDLE_DIR   = Path("/home/loreto/filu/Applications/bundles") / PROJECT_NAME
    BUNDLE_DIR.mkdir(parents=True, exist_ok=True)



    ### - file contente il progetto
    PYZ_FILE     = DIST_DIR / f"{PROJECT_NAME}.pyz"
    PYZ_TO_UTIL  = SCRIPT_DIR / f"{PROJECT_NAME}.pyz"

    ### - numero max di backups
    MAX_HISTORY  = 10

    ### - file che deve esistere altrimenti ignoriamo il launch
    MAIN_FILE    = BASE_DIR / "__main__.py"
    SRC_DIR      = BASE_DIR / "src"

    INCLUDE_DIRS=[
                    "source",
                    "conf",
                    "modules",
                ]

    main()