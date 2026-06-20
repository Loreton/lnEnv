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
        self.root_dir = Path(__file__).parent.absolute()
        self.project_name = self.root_dir.name
        self.dist_dir = self.root_dir / "dist"
        self.version = self.get_version()
        self.pyLnLib_path = self.root_dir.parent / "pyLnLib/src/pyLnLib"

    def get_version(self) -> str:
        """Recupera la versione da library.json"""
        library_json = self.root_dir / "library.json"
        if library_json.exists():
            try:
                with open(library_json) as f:
                    data = json.load(f)
                    if "version" in data:
                        return data["version"]
            except:
                pass
        return datetime.now().strftime("%Y%m%d_%H%M%S")

    def create_pyz(self):
        """Crea un PYZ eseguibile con struttura piatta"""
        print("\n📦 Creazione PYZ eseguibile...")

        with tempfile.TemporaryDirectory() as temp_dir_str:
            temp_dir = Path(temp_dir_str)

            # 1. Copia pyLnLib (directory parent)
            pyLnLib_path = self.root_dir.parent / "pyLnLib/src/pyLnLib"
            if pyLnLib_path.exists():
                print(f"   • Copiando pyLnLib da: {pyLnLib_path}")
                shutil.copytree(pyLnLib_path, temp_dir / "pyLnLib" ,
                              ignore=shutil.ignore_patterns('__pycache__', '*.pyc', '.venv', '.git'))

            # 2. Copia lnsync (src/lnsync → lnsync)
            src_lnsync = self.root_dir / "src" / "lnsync"
            if src_lnsync.exists():
                print(f"   • Copiando lnsync da: {src_lnsync}")
                shutil.copytree(src_lnsync, temp_dir / "lnsync",
                              ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))

            # 3. Copia conf
            conf_path = self.root_dir / "conf"
            if conf_path.exists():
                print(f"   • Copiando conf")
                shutil.copytree(conf_path, temp_dir / "conf",
                              ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))

            # 4. Crea __main__.py semplice
            main_content = '''#!/usr/bin/env python3
import sys
from pathlib import Path

# Aggiungi la directory corrente al path
sys.path.insert(0, str(Path(__file__).parent))

# Importa ed esegui main
from lnsync.main import main

if __name__ == "__main__":
    sys.exit(main())
'''
            (temp_dir / "__main__.py").write_text(main_content)

            # 5. Crea il PYZ
            pyz_path = self.dist_dir / f"{self.project_name}_{self.version}.pyz"
            zipapp.create_archive(str(temp_dir), target=str(pyz_path), interpreter="/usr/bin/env python3")
            pyz_path.chmod(0o755)

            print(f"✅ PYZ creato: {pyz_path}")
            print(f"📊 Dimensione: {pyz_path.stat().st_size / (1024 * 1024):.2f} MB")

            # Test rapido
            print("   • Testando...")
            result = subprocess.run([sys.executable, str(pyz_path), "--help"],
                                  capture_output=True, text=True)
            if result.returncode == 0:
                print("   ✅ Test superato!")
            else:
                print(f"   ⚠️  Test fallito: {result.stderr[:200]}")

    def create_bundle(self):
        """Crea il bundle portabile"""
        print("\n🎒 Creazione bundle portabile...")

        temp_dir = self.root_dir / f"temp_bundle_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        temp_dir.mkdir(exist_ok=True)

        try:
            # Crea venv
            print("   • Creando virtual environment...")
            venv_path = temp_dir / ".venv"
            subprocess.run([sys.executable, "-m", "venv", str(venv_path)], check=True)

            # Installa dipendenze base
            print("   • Installando dipendenze...")
            pip = venv_path / "bin" / "pip"

            # Installa pyLnLib in modalità editable
            pyLnLib_path = self.root_dir.parent / "pyLnLib"
            if pyLnLib_path.exists():
                subprocess.run([str(pip), "install", "-e", str(pyLnLib_path)], check=False)

            # Installa il progetto corrente
            subprocess.run([str(pip), "install", "-e", str(self.root_dir)], check=False)

            # Copia file di configurazione
            shutil.copytree(self.root_dir / "conf", temp_dir / "conf",
                          ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))

            # Crea script di avvio
            script = temp_dir / "run.sh"
            script.write_text(f'''#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
source "$SCRIPT_DIR/.venv/bin/activate"
python -m lnsync.main "$@"
''')
            script.chmod(0o755)

            # Crea tarball
            bundle_path = self.dist_dir / f"{self.project_name}_{self.version}_bundle.tar.gz"
            with tarfile.open(bundle_path, "w:gz") as tar:
                tar.add(temp_dir, arcname=f"{self.project_name}_bundle")

            print(f"✅ Bundle creato: {bundle_path}")
            print(f"📊 Dimensione: {bundle_path.stat().st_size / (1024 * 1024):.2f} MB")

        finally:
            shutil.rmtree(temp_dir, ignore_errors=True)

    def clean(self):
        """Pulisci"""
        print("🧹 Pulendo...")
        if self.dist_dir.exists():
            shutil.rmtree(self.dist_dir)
        self.dist_dir.mkdir()
        print("✅ Pulito!")

    def run(self):
        print(f"🔨 {self.project_name} Build Tool v{self.version}")
        print("=" * 40)

        self.dist_dir.mkdir(exist_ok=True)

        if self.args.clean:
            self.clean()
        elif self.args.build:
            self.create_pyz()
        elif self.args.bundle:
            self.create_bundle()
        else:
            self.create_pyz()
            self.create_bundle()

        print("\n✨ Build completata!")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--build", action="store_true", help="Build solo PYZ")
    parser.add_argument("--bundle", action="store_true", help="Build solo bundle")
    parser.add_argument("--clean", action="store_true", help="Pulisci")
    args = parser.parse_args()

    ProjectBuilder(args).run()

if __name__ == "__main__":
    main()