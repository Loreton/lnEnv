#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-05-2026 15.40.11
#

import sys; sys.dont_write_bytecode = True
import os


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
