#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-05-2026 15.49.36
#

import sys; sys.dont_write_bytecode = True
import os



#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-05-2026 15.49.36
#
import sys; sys.dont_write_bytecode=True
from dataclasses import dataclass
from datetime import datetime
import socket
import platform
import yaml
import zipfile
from pathlib import Path

# from .yaml_loader_class import YamlEngine, AppEnvironment

@dataclass(frozen=True) # "frozen" rende i colori non modificabili per errore
class Colors:
    red: str    = '\033[31m'; redH: str    = '\033[91m'
    green: str  = '\033[32m'; greenH: str  = '\033[92m'
    yellow: str = '\033[33m'; yellowH: str = '\033[93m'
    blue: str   = '\033[34m'; blueH: str   = '\033[94m'
    purple: str = '\033[35m'; purpleH: str = '\033[95m'
    magenta: str = '\033[35m'; magentaH: str = '\033[95m'
    cyan: str   = '\033[36m'; cyanH: str   = '\033[96m'
    white: str  = '\033[37m'; whiteH: str  = '\033[97m'
    reset: str  = '\033[0m'


# @dataclass
class GlobalVars:
    # project_name: str = "git_commit"
    fExecute: bool = False

    colors: Colors = Colors()


    SCRIPT_DIR = Path(__file__).resolve().parent
    BASE_DIR = Path.cwd()
    PROJECT_NAME = BASE_DIR.name

    # External libraries
    pyLnLib_name = "pyLnLib"
    pyLnLib_SRC = Path(f"/home/loreto/filu/Programming/gitREPO/{pyLnLib_name}/src/{pyLnLib_name}")

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





# 👉 ISTANZA VERA
gVars = GlobalVars()

