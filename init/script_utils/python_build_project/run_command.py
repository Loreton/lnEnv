#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-05-2026 15.45.03
#

import sys; sys.dont_write_bytecode = True
import os
import shutil
import zipapp
import subprocess
import tomllib
from pathlib import Path
from typing import List, Optional, Dict


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
