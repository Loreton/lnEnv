#!/usr/bin/env python3

"""
build_bundle.py - Script per costruire bundle e sdist di lnSync con gestione storico
"""

import os
import shutil
import subprocess
import sys
import tarfile
import json
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional

class BundleBuilder:
    def __init__(self, args):
        self.args = args
        self.root_dir = Path(__file__).parent.absolute()
        self.venv_dir = self.root_dir / ".venv"
        self.dist_dir = self.root_dir / "dist"
        self.history_dir = None
        self.project_name = "lnSync"
        self.max_history = 10
        self.version = self.get_version()

    def get_version(self) -> str:
        """Recupera la versione da library.json o pyproject.toml"""
        # Prova a leggere da library.json
        library_json = self.root_dir / "library.json"
        if library_json.exists():
            try:
                with open(library_json) as f:
                    data = json.load(f)
                    if "version" in data:
                        return data["version"]
            except:
                pass

        # Fallback a pyproject.toml
        pyproject = self.root_dir / "pyproject.toml"
        if pyproject.exists():
            try:
                import tomllib
                with open(pyproject, "rb") as f:
                    data = tomllib.load(f)
                    if "project" in data and "version" in data["project"]:
                        return data["project"]["version"]
            except:
                pass

        # Fallback a data corrente
        return datetime.now().strftime("%Y%m%d_%H%M%S")

    def rotate_previous_build(self, file: Path, file_type: str = "pyz"):
        """Ruota lo storico dei build"""
        if not self.history_dir:
            print("❌ History directory non specificata")
            return

        self.history_dir.mkdir(parents=True, exist_ok=True)

        if not file.exists():
            return

        print(f"🔄 Rotating {file_type} build history")

        # Usa l'estensione corretta
        extension = file.suffix
        prefix = f"{self.project_name}_{self.version}_v"

        # Ruota dalla versione più vecchia alla più nuova
        for i in range(self.max_history, 1, -1):
            src = self.history_dir / f"{prefix}{i-1:02d}{extension}"
            dst = self.history_dir / f"{prefix}{i:02d}{extension}"
            if src.exists():
                src.replace(dst)

        # Salva la versione più recente
        latest = self.history_dir / f"{prefix}01{extension}"
        file.replace(latest)
        print(f"✅ Saved previous build as: {latest}")

    def check_requirements(self):
        """Verifica prerequisiti"""
        print("🔍 Verificando prerequisiti...")

        if not self.venv_dir.exists():
            print("❌ Virtual environment non trovato. Esegui 'uv venv' prima.")
            return False

        return True

    def get_editable_packages(self) -> List[Dict]:
        """Recupera pacchetti installati in modalità editable"""
        print("📦 Rilevando pacchetti editable da pyproject.toml...")
        editable_packages = []

        # Leggi pyproject.toml per trovare dipendenze editable
        pyproject = self.root_dir / "pyproject.toml"
        if pyproject.exists():
            try:
                import tomllib
                with open(pyproject, "rb") as f:
                    data = tomllib.load(f)

                    # Cerca dipendenze con path locali
                    if "project" in data and "dependencies" in data["project"]:
                        for dep in data["project"]["dependencies"]:
                            if "-e " in dep or "editable" in dep or dep.startswith("."):
                                # Estrai il path
                                if " " in dep:
                                    path_part = dep.split()[-1]
                                    if path_part.startswith("."):
                                        pkg_path = self.root_dir / path_part
                                        if pkg_path.exists():
                                            editable_packages.append({
                                                'name': pkg_path.name,
                                                'path': pkg_path,
                                                'spec': dep
                                            })
            except Exception as e:
                print(f"⚠️  Errore nel leggere pyproject.toml: {e}")

        # Alternativa: controlla se pyLnLib è installato
        pyLnLib_path = self.root_dir.parent / "pyLnLib"
        if pyLnLib_path.exists():
            editable_packages.append({
                'name': 'pyLnLib',
                'path': pyLnLib_path,
                'spec': '-e ../pyLnLib'
            })
            print(f"   ✓ Trovato pyLnLib in: {pyLnLib_path}")

        return editable_packages

    def create_source_distribution(self):
        """Crea la source distribution (sdist)"""
        print("\n📦 Creazione source distribution...")

        # Crea directory temporanea
        temp_dir = self.root_dir / f"temp_sdist_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        temp_dir.mkdir(exist_ok=True)

        try:
            # Copia i file del progetto
            self.copy_project_files(temp_dir, include_venv=False)

            # Copia i pacchetti editable
            editable_packages = self.get_editable_packages()
            for pkg in editable_packages:
                print(f"   • Includendo pacchetto editable: {pkg['name']}")
                target_pkg = temp_dir / "external_packages" / pkg['path'].name
                shutil.copytree(pkg['path'], target_pkg,
                              ignore=shutil.ignore_patterns('__pycache__', '*.pyc', '.venv', '.git'))

            # Crea setup.py per sdist
            self.create_setup_py(temp_dir, editable_packages)

            # Crea MANIFEST.in
            self.create_manifest(temp_dir)

            # Crea lo script di installazione
            self.create_install_script(temp_dir, for_bundle=False)

            # Crea il tarball
            sdist_name = f"{self.project_name}-{self.version}.tar.gz"
            sdist_path = self.dist_dir / sdist_name

            with tarfile.open(sdist_path, "w:gz") as tar:
                tar.add(temp_dir, arcname=f"{self.project_name}-{self.version}")

            print(f"✅ Source distribution creata: {sdist_path}")

            # Gestisci storico se richiesto
            if self.history_dir:
                self.rotate_previous_build(sdist_path, "sdist")

            return sdist_path

        finally:
            shutil.rmtree(temp_dir, ignore_errors=True)

    def create_portable_bundle(self):
        """Crea il bundle portabile con venv"""
        print("\n🎒 Creazione bundle portabile...")

        # Crea directory temporanea
        temp_dir = self.root_dir / f"temp_bundle_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        temp_dir.mkdir(exist_ok=True)

        try:
            # Copia tutto nel bundle
            self.copy_venv(temp_dir)
            self.copy_project_files(temp_dir, include_venv=False)
            self.handle_editable_packages(temp_dir)
            self.create_start_script(temp_dir)
            self.create_install_script(temp_dir, for_bundle=True)

            # Crea il file tar.gz
            bundle_name = f"{self.project_name}_{self.version}_bundle.tar.gz"
            bundle_path = self.dist_dir / bundle_name

            with tarfile.open(bundle_path, "w:gz") as tar:
                tar.add(temp_dir, arcname=f"{self.project_name}_bundle")

            # Calcola la dimensione
            size_mb = bundle_path.stat().st_size / (1024 * 1024)
            print(f"✅ Bundle creato: {bundle_path}")
            print(f"📊 Dimensione: {size_mb:.2f} MB")

            # Gestisci storico se richiesto
            if self.history_dir:
                self.rotate_previous_build(bundle_path, "bundle")

            return bundle_path

        finally:
            shutil.rmtree(temp_dir, ignore_errors=True)

    def copy_venv(self, temp_dir):
        """Copia il virtual environment"""
        print("📦 Copiando virtual environment...")
        target_venv = temp_dir / ".venv"

        shutil.copytree(
            self.venv_dir,
            target_venv,
            ignore=shutil.ignore_patterns('__pycache__', '*.pyc', '.git', '*.egg-info')
        )

        # Preserva permessi eseguibili
        for bin_file in target_venv.glob("bin/*"):
            if bin_file.is_file():
                bin_file.chmod(0o755)

    def copy_project_files(self, temp_dir, include_venv=False):
        """Copia i file del progetto"""
        print("📁 Copiando i file del progetto...")

        include_items = [
            'src', 'tests', 'conf', 'scripts',
            'pyproject.toml', 'README.md', 'CHANGELOG.md',
            'library.json', 'uv.lock'
        ]

        exclude_dirs = {'__pycache__', '.git', '.pytest_cache', '.mypy_cache', 'dist', '.venv'}

        for item in include_items:
            source = self.root_dir / item
            if source.exists():
                if source.is_dir():
                    shutil.copytree(
                        source,
                        temp_dir / item,
                        ignore=lambda d, f: [f for f in f if f in exclude_dirs or f.endswith('.pyc')]
                    )
                else:
                    shutil.copy2(source, temp_dir / item)

    def handle_editable_packages(self, temp_dir):
        """Gestisce i pacchetti editable nel bundle"""
        print("🔗 Gestendo pacchetti editable...")
        editable_packages = self.get_editable_packages()

        if not editable_packages:
            print("   Nessun pacchetto editable trovato")
            return

        external_dir = temp_dir / "external_packages"
        external_dir.mkdir(exist_ok=True)

        for pkg in editable_packages:
            print(f"   • Includendo {pkg['name']} da {pkg['path']}")

            target_pkg = external_dir / pkg['path'].name
            if not target_pkg.exists():
                shutil.copytree(pkg['path'], target_pkg,
                              ignore=shutil.ignore_patterns('__pycache__', '*.pyc', '.venv', '.git'))

        self.create_editable_config(temp_dir, editable_packages)

    def create_editable_config(self, temp_dir, editable_packages):
        """Crea script per ricreare link editable"""
        setup_script = temp_dir / "setup_editable_links.py"

        script_content = '''#!/usr/bin/env python3
import os
import sys
from pathlib import Path

def setup_editable_links():
    current_dir = Path(__file__).parent
    venv_dir = current_dir / ".venv"

    if not venv_dir.exists():
        print("⚠️  Virtual environment non trovato")
        return

    python_version = f"{sys.version_info.major}.{sys.version_info.minor}"
    site_packages = venv_dir / "lib" / f"python{python_version}" / "site-packages"
    site_packages.mkdir(parents=True, exist_ok=True)

    external_dir = current_dir / "external_packages"
    if not external_dir.exists():
        print("Nessun pacchetto esterno trovato")
        return

    for pkg_dir in external_dir.iterdir():
        if pkg_dir.is_dir():
            pth_file = site_packages / f"{pkg_dir.name}.pth"
            with open(pth_file, 'w') as f:
                f.write(str(pkg_dir.absolute()))
            print(f"✓ Link creato per {pkg_dir.name}")

    print("✅ Setup pacchetti editable completato!")

if __name__ == "__main__":
    setup_editable_links()
'''

        with open(setup_script, 'w') as f:
            f.write(script_content)
        setup_script.chmod(0o755)

    def create_start_script(self, temp_dir):
        """Crea script di avvio"""
        start_script = temp_dir / "run_lnsync.sh"

        script_content = f'''#!/bin/bash
# lnSync - Portable Bundle v{self.version}

SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"

source "$SCRIPT_DIR/.venv/bin/activate"

if [ -f "$SCRIPT_DIR/setup_editable_links.py" ]; then
    python "$SCRIPT_DIR/setup_editable_links.py"
fi

python -m src.lnsync.main "$@"
'''

        with open(start_script, 'w') as f:
            f.write(script_content)
        start_script.chmod(0o755)

        # Versione Windows
        start_bat = temp_dir / "run_lnsync.bat"
        bat_content = f'''@echo off
REM lnSync - Portable Bundle v{self.version}

set SCRIPT_DIR=%~dp0

call "%SCRIPT_DIR%\\.venv\\Scripts\\activate.bat"

if exist "%SCRIPT_DIR%\\setup_editable_links.py" (
    python "%SCRIPT_DIR%\\setup_editable_links.py"
)

python -m src.lnsync.main %*
'''
        with open(start_bat, 'w') as f:
            f.write(bat_content)

    def create_install_script(self, temp_dir, for_bundle=True):
        """Crea script di installazione"""
        if for_bundle:
            install_script = temp_dir / "install.sh"
            content = f'''#!/bin/bash
# Installa lnSync v{self.version} dal bundle

echo "📦 Installazione lnSync..."
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
python setup_editable_links.py
echo "✅ Installazione completata!"
'''
        else:
            install_script = temp_dir / "install.sh"
            content = f'''#!/bin/bash
# Installa lnSync v{self.version} da source

echo "📦 Installazione lnSync..."
pip install --upgrade pip
pip install -e .
echo "✅ Installazione completata!"
'''

        with open(install_script, 'w') as f:
            f.write(content)
        install_script.chmod(0o755)

    def create_setup_py(self, temp_dir, editable_packages):
        """Crea setup.py per sdist"""
        setup_content = f'''from setuptools import setup, find_packages

setup(
    name="{self.project_name}",
    version="{self.version}",
    packages=find_packages(),
    install_requires=[
        # Le dipendenze vengono da pyproject.toml
    ],
    entry_points={{
        "console_scripts": [
            "lnsync=src.lnsync.main:main",
        ],
    }},
    python_requires=">=3.8",
)
'''
        with open(temp_dir / "setup.py", 'w') as f:
            f.write(setup_content)

    def create_manifest(self, temp_dir):
        """Crea MANIFEST.in"""
        manifest_content = '''include pyproject.toml
include README.md
include CHANGELOG.md
include library.json
recursive-include src *.py
recursive-include conf *.yaml *.yml
recursive-include external_packages *
'''
        with open(temp_dir / "MANIFEST.in", 'w') as f:
            f.write(manifest_content)

    def clean_builds(self):
        """Pulisce i build esistenti"""
        print("🧹 Pulendo build esistenti...")

        # Pulisci dist directory
        if self.dist_dir.exists():
            shutil.rmtree(self.dist_dir)
            self.dist_dir.mkdir()
            print("   ✓ Pulita directory dist/")

        # Pulisci directory temporanee
        for temp_dir in self.root_dir.glob("temp_*"):
            shutil.rmtree(temp_dir)
            print(f"   ✓ Pulita {temp_dir.name}")

        # Pulisci cache Python
        for pycache in self.root_dir.glob("**/__pycache__"):
            shutil.rmtree(pycache)
            print(f"   ✓ Pulita {pycache}")

    def run(self):
        """Esegue il processo di building"""
        print(f"🔨 lnSync Build Tool v{self.version}")
        print("=" * 50)

        # Gestisci history directory
        if self.args.project:
            self.history_dir = Path(self.args.project) / "build_history"
            print(f"📂 History directory: {self.history_dir}")

        # Clean build
        if self.args.clean:
            self.clean_builds()
            return

        # Check requirements
        if not self.check_requirements():
            sys.exit(1)

        # Crea dist directory
        self.dist_dir.mkdir(exist_ok=True)

        # Build specifico o tutti
        if self.args.sdist:
            self.create_source_distribution()
        elif self.args.bundle:
            self.create_portable_bundle()
        else:
            # Build tutto
            self.create_source_distribution()
            self.create_portable_bundle()

        print("\n✨ Build completata con successo!")

def main():
    parser = argparse.ArgumentParser(description="lnSync Build Tool")
    parser.add_argument("-p", "--project", help="Project root directory for history")
    parser.add_argument("--clean", action="store_true", help="Clean builds only")
    parser.add_argument("--sdist", action="store_true", help="Build only source dist")
    parser.add_argument("--bundle", action="store_true", help="Build only portable bundle")

    args = parser.parse_args()

    builder = BundleBuilder(args)
    builder.run()

if __name__ == "__main__":
    main()