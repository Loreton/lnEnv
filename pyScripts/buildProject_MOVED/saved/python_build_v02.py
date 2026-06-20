#!/usr/bin/env python3
"""
build.py - Script per costruire bundle e PYZ di lnSync
"""

import os
import shutil
import subprocess
import sys
import tarfile
import json
import argparse
import zipapp
import tempfile
from pathlib import Path
from datetime import datetime

class ProjectBuilder:
    def __init__(self, args):
        self.args = args
        # self.project_root_dir = Path(__file__).parent.absolute()
        self.project_root_dir = Path.cwd()
        self.project_name     = self.project_root_dir.name
        self.target_root_dir  = Path("/home/loreto/filu/Applications/lnAppls") / self.project_name
        # self.build_dir        = Path("/tmp") / self.project_name


        self.pyLnLib_path     = self.project_root_dir.parent / "pyLnLib/src/pyLnLib"
        self.conf_path        = self.project_root_dir / "conf"
        self.version          = self.get_version()
        self.dist_dir         = self.target_root_dir / "dist"
        self.history_dir      = self.target_root_dir / "history" if args.history else None
        self.max_history      = 10
        # self.production       = args.production

        self.target_root_dir.mkdir(parents=True, exist_ok=True)

        if self.checkPythonProjectDir():
            print("=" * 40)
            print(f"\t{str(self.project_name)     = }")
            print(f"\t{str(self.version)          = }")
            print()
            print(f"\t{str(self.project_root_dir) = }")
            print(f"\t{str(self.pyLnLib_path)     = }")
            print(f"\t{str(self.conf_path)        = }")
            print()
            print(f"\t{str(self.target_root_dir)  = }")
            print(f"\t{str(self.dist_dir)         = }")
            print(f"\t{str(self.history_dir)      = }")
            print()
            print("=" * 40)
        else:
            sys.exit(1)


    def checkPythonProjectDir(self) -> str:
        if not (self.project_root_dir / ".venv").is_dir():
            print("ERROR: directory .venv not found!")
            return False

        elif not (self.project_root_dir / "pyproject.toml").is_file():
            print("ERROR: file pyproject.toml not found!")
            return False

        elif not (self.project_root_dir / "library.json").is_file():
            print("ERROR: file library.json not found!")
            return False

        return True



    def rotate_previous_build(self, file: Path, file_type: str = "pyz") -> str:
        """Ruota lo storico dei build"""
        if not self.history_dir:
            print("❌ History directory non specificata")
            return

        self.history_dir.mkdir(parents=True, exist_ok=True)

        if not file.exists():
            return

        print(f"🔄 Rotating {file_type} build history")
        if file_type=='pyz': file_type='bin'

        # Usa l'estensione corretta
        extension = file.suffix
        prefix = f"{self.project_name}_{file_type}_{self.version}_v"

        # Ruota dalla versione più vecchia alla più nuova
        for i in range(self.max_history, 1, -1):
            src = self.history_dir / f"{prefix}{i-1:02d}{extension}"
            dst = self.history_dir / f"{prefix}{i:02d}{extension}"
            if src.exists():
                print(f"moving version {prefix}{i-1:02d}{extension} to {prefix}{i:02d}{extension}")
                src.replace(dst)

        # Salva la versione più recente
        latest = self.history_dir / f"{prefix}01{extension}"
        # shutil.copy2(file, latest) # evitiamo di rimuoverlo da dist
        file.replace(latest)  # lo rimuove anche da dist
        print(f"✅ Saved previous build as: {latest}")
        return latest



    def get_version(self) -> str:
        """Recupera la versione da library.json"""
        library_json = self.project_root_dir / "library.json"
        if library_json.exists():
            try:
                with open(library_json) as f:
                    data = json.load(f)
                    if "version" in data:
                        return data["version"]
            except:
                pass
        return datetime.now().strftime("%Y%m%d_%H%M%S")

    def get_content(self, what: str=None):
        if content == 'main':
        # 4. Crea __main__.py
            content = f'''#!/usr/bin/env python3
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from {self.project_name.lower()}.main import main

if __name__ == "__main__":
    sys.exit(main())
'''
        elif what == 'script':
            content = f'''#!/bin/bash
# {self.project_name} v{self.version} - Portable Bundle

SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
source "$SCRIPT_DIR/.venv/bin/activate"
python "$SCRIPT_DIR/{pyz_path.name}" "$@"
'''
        elif what == 'bat':
            # Versione Windows
            bat_content = f'''@echo off
set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%\\.venv\\Scripts\\activate.bat"
python "%SCRIPT_DIR%\\{pyz_path.name}" %*
'''

        else:
            content = None

        return content


    def create_pyz(self) -> str:
        """Crea un PYZ eseguibile con struttura piatta"""
        print("\n📦 Creazione PYZ eseguibile...")

        with tempfile.TemporaryDirectory() as temp_dir_str:
            temp_dir = Path(temp_dir_str)

            # 1. Copia pyLnLib
            if self.pyLnLib_path.exists():
                print(f"   • Copiando pyLnLib da: {self.pyLnLib_path}")
                shutil.copytree(self.pyLnLib_path, temp_dir / "pyLnLib",
                              ignore=shutil.ignore_patterns('__pycache__', '*.pyc', '.venv', '.git'))

            # 2. Copia lnsync
            my_source = self.project_root_dir / "src" / self.project_name.lower()
            if my_source.exists():
                print(f"   • Copying source from: {my_source}")
                shutil.copytree(my_source, temp_dir / self.project_name.lower(), ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))

            # 3. Copia conf
            if self.conf_path.exists():
                print(f"   • Copying conf")
                shutil.copytree(self.conf_path, temp_dir / "conf", ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))

            # 4. Crea __main__.py
            main_content = f'''#!/usr/bin/env python3
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from {self.project_name.lower()}.main import main

if __name__ == "__main__":
    sys.exit(main())
'''
            # (temp_dir / "__main__.py").write_text(main_content)
            (temp_dir / "__main__.py").write_text(get_content(what='main'))

            # 5. Crea il PYZ
            pyz_path = self.dist_dir / f"{self.project_name}_{self.version}.pyz"
            zipapp.create_archive(str(temp_dir), target=str(pyz_path), interpreter="/usr/bin/env python3")
            pyz_path.chmod(0o755)

            print(f"✅ PYZ creato: {pyz_path}")
            print(f"📊 Dimensione: {pyz_path.stat().st_size / (1024 * 1024):.2f} MB")

            # Test rapido
            print("   • Testing...")
            result = subprocess.run([sys.executable, str(pyz_path), "--help"], capture_output=True, text=True)
            if result.returncode == 0:
                print("   ✅ run test is OK!")
            else:
                print(f"   ⚠️ run test failed: {result.stderr[:200]}")
                print(f"   ⚠️ run test failed: {result.stderr}")


            return pyz_path

    def create_bundle(self):
        """Crea il bundle portabile (PYZ + venv)"""
        print("\n🎒 Creazione bundle portabile...")

        # Prima crea il PYZ
        pyz_path = self.create_pyz()

        # Crea directory temporanea per il bundle
        temp_dir = self.project_root_dir / f"temp_bundle_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        temp_dir.mkdir(exist_ok=True)

        try:
            # 1. Copia il PYZ
            print("   • Copiando PYZ nel bundle...")
            shutil.copy2(pyz_path, temp_dir / pyz_path.name)

            # 2. Crea virtual environment
            print("   • Creando virtual environment...")
            venv_path = temp_dir / ".venv"
            subprocess.run([sys.executable, "-m", "venv", str(venv_path)], check=True)

            # 3. Installa le dipendenze base
            print("   • Installando dipendenze base...")
            pip = venv_path / "bin" / "pip"

            dependencies = []
            pyproject = self.project_root_dir / "pyproject.toml"
            if pyproject.exists():
                try:
                    import tomllib
                    with open(pyproject, "rb") as f:
                        data = tomllib.load(f)
                        if "project" in data and "dependencies" in data["project"]:
                            for dep in data["project"]["dependencies"]:
                                if not any(x in dep for x in ['pyLnLib', '-e', '../', './', 'editable']):
                                    dependencies.append(dep)
                except:
                    pass

            if dependencies:
                print(f"   • Installando: {', '.join(dependencies[:3])}{'...' if len(dependencies) > 3 else ''}")
                subprocess.run([str(pip), "install", *dependencies], check=False)
            else:
                print("   • Nessuna dipendenza esterna da installare")

            # 4. Crea script di avvio
            print("   • Creando script di avvio...")
            script_content = f'''#!/bin/bash
# {self.project_name} v{self.version} - Portable Bundle

SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
source "$SCRIPT_DIR/.venv/bin/activate"
python "$SCRIPT_DIR/{pyz_path.name}" "$@"
'''
            run_script = temp_dir / "run.sh"
            run_script.write_text(script_content)
            run_script.chmod(0o755)

            # Versione Windows
            bat_content = f'''@echo off
set SCRIPT_DIR=%~dp0
call "%SCRIPT_DIR%\\.venv\\Scripts\\activate.bat"
python "%SCRIPT_DIR%\\{pyz_path.name}" %*
'''
            run_bat = temp_dir / "run.bat"
            run_bat.write_text(bat_content)

            # 5. Crea README
            print("   • Creando README...")
            readme_content = f'''# {self.project_name} v{self.version} - Portable Bundle

## Utilizzo
Linux/macOS: ./run.sh --help
Windows: run.bat --help

## Contenuto
- {pyz_path.name}: Applicazione principale
- .venv/: Python environment con dipendenze
- run.sh/run.bat: Script di avvio
'''
            (temp_dir / "README.txt").write_text(readme_content)

            # 6. Crea il tarball (questa parte mancava!)
            print("   • Creando archive tar.gz...")
            # bundle_name = f"{self.project_name}_{self.version}_bundle.tar.gz"
            bundle_name = f"{self.project_name}_{self.version}_bundle.tgz"
            bundle_path = self.dist_dir / bundle_name

            with tarfile.open(bundle_path, "w:gz") as tar:
                tar.add(temp_dir, arcname=f"{self.project_name}_bundle")

            print(f"✅ Bundle creato: {bundle_path}")
            print(f"📊 Dimensione: {bundle_path.stat().st_size / (1024 * 1024):.2f} MB")

            print("\n📁 Struttura del bundle:")
            print(f"   {self.project_name}_bundle/")
            print(f"   ├── {pyz_path.name}")
            print(f"   ├── .venv/")
            print(f"   ├── run.sh")
            print(f"   ├── run.bat")
            print(f"   └── README.txt")

        except Exception as e:
            print(f"   ❌ Errore durante la creazione del bundle: {e}")
            raise

        finally:
            # Pulisci directory temporanea
            print("   • Pulendo directory temporanea...")
            shutil.rmtree(temp_dir, ignore_errors=True)

        return bundle_path


    def clean(self):
        """Pulisci dist dir"""
        print("🧹 Pulendo...")
        if self.dist_dir.exists():
            shutil.rmtree(self.dist_dir)
        self.dist_dir.mkdir()
        print("✅ Pulito!")

    def run(self):

        choice=input("press 'c' to continue, any key to exit").lower()
        if not choice == 'c':
            print("Exiting on user request.")
            sys.exit(0)


        self.dist_dir.mkdir(exist_ok=True)

        if self.args.clean:
            self.clean()

        elif self.args.build:
            pyz_path = self.create_pyz()
            if self.history_dir:
                latest               = self.rotate_previous_build(pyz_path, "pyz")
                latest_relative_path = latest.relative_to(self.target_root_dir)
                link_name            = self.target_root_dir / f"{self.project_name}_lnk.pyz"
                print(f"   • Creating {link_name} --> {latest_relative_path}")
                subprocess.run(["ln", "-sfn", latest_relative_path, link_name ])

        elif self.args.bundle:
            bundle_path = self.create_bundle()
            if self.history_dir:
                latest               = self.rotate_previous_build(bundle_path, "bundle")
                link_name            = self.target_root_dir / f"{self.project_name}_lnk.tgz"
                latest_relative_path = latest.relative_to(self.target_root_dir)
                print(f"   • Creating {link_name} --> {latest_relative_path}")
                subprocess.run(["ln", "-sfn", latest_relative_path, link_name ])

        else:
            print("\n❌ Enter a vaild option!")
            sys.exit(1)

        print("\n✨ Build completata!")

def main():
    if len(sys.argv) == 1:
       sys.argv.append("-h")
    parser = argparse.ArgumentParser(description="Build Tool for python project")
    parser.add_argument("--history", action="store_true", help="create history of package")


    group=parser.add_argument_group(f'--------- action options')
    action=group.add_mutually_exclusive_group(required=True)

    action.add_argument("--build", action="store_true", help="Build PYZ")
    action.add_argument("--bundle", action="store_true", help="Build PYZ and bundle")
    action.add_argument("--clean", action="store_true", help="Clean dist area")


    # parser.add_argument("--build", action="store_true", help="Build solo PYZ")
    # parser.add_argument("--bundle", action="store_true", help="Build solo bundle")
    # parser.add_argument("--clean", action="store_true", help="Pulisci")
    args = parser.parse_args()



    ProjectBuilder(args).run()

if __name__ == "__main__":
    main()