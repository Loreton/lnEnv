#!/usr/bin/env python3
"""
build_bundle.py - Script per creare un bundle di lnSync con venv e dipendenze
"""

import os
import shutil
import subprocess
import sys
import tarfile
from pathlib import Path
from datetime import datetime

class BundleBuilder:
    def __init__(self):
        self.root_dir = Path(__file__).parent.absolute()
        self.venv_dir = self.root_dir / ".venv"
        self.dist_dir = self.root_dir / "dist"
        self.bundle_name = f"lnSync_bundle_{datetime.now().strftime('%Y%m%d_%H%M%S')}.tar.gz"

    def check_requirements(self):
        """Verifica che tutti i prerequisiti siano soddisfatti"""
        print("🔍 Verificando prerequisiti...")

        if not self.venv_dir.exists():
            print("❌ Virtual environment non trovato. Esegui 'uv venv' prima.")
            return False

        # Verifica che pyLnLib sia installato in modalità editable
        try:
            result = subprocess.run(
                [self.venv_dir / "bin" / "python", "-c", "import pyLnLib; print(pyLnLib.__file__)"],
                capture_output=True,
                text=True
            )
            if "site-packages" in result.stdout:
                print("⚠️  pyLnLib sembra essere installato normalmente, non in modalità editable")
                print("   Per installarlo in modalità editable: uv pip install -e /path/to/pyLnLib")
        except:
            print("⚠️  pyLnLib non trovato o non importabile")

        return True

    def get_editable_packages(self):
        """Recupera la lista dei pacchetti installati in modalità editable"""
        print("📦 Rilevando pacchetti editable...")
        editable_packages = []

        try:
            # Leggi il file site-packages per trovare i link .pth o .egg-link
            site_packages = self.venv_dir / "lib" / f"python{sys.version_info.major}.{sys.version_info.minor}" / "site-packages"

            for pth_file in site_packages.glob("*.pth"):
                with open(pth_file) as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith("#"):
                            path = Path(line)
                            if path.exists():
                                editable_packages.append({
                                    'name': pth_file.stem,
                                    'path': path,
                                    'type': '.pth'
                                })

            for egg_link in site_packages.glob("*.egg-link"):
                with open(egg_link) as f:
                    line = f.readline().strip()
                    if line:
                        path = Path(line)
                        if path.exists():
                            editable_packages.append({
                                'name': egg_link.stem.replace('.egg', ''),
                                'path': path,
                                'type': '.egg-link'
                            })
        except Exception as e:
            print(f"⚠️  Errore nel rilevare pacchetti editable: {e}")

        return editable_packages

    def copy_venv(self, temp_dir):
        """Copia il virtual environment nel bundle"""
        print("📦 Copiando virtual environment...")
        target_venv = temp_dir / ".venv"

        # Escludi __pycache__ e .pyc per ridurre la dimensione
        shutil.copytree(
            self.venv_dir,
            target_venv,
            ignore=shutil.ignore_patterns('__pycache__', '*.pyc', '.git', '*.egg-info')
        )

        # Su Linux/macOS, preserva i permessi eseguibili
        for bin_file in target_venv.glob("bin/*"):
            if bin_file.is_file():
                bin_file.chmod(0o755)

        return target_venv

    def handle_editable_packages(self, temp_dir):
        """Gestisce i pacchetti installati in modalità editable"""
        print("🔗 Gestendo pacchetti editable...")
        editable_packages = self.get_editable_packages()

        if not editable_packages:
            print("   Nessun pacchetto editable trovato")
            return

        for pkg in editable_packages:
            print(f"   • {pkg['name']} ({pkg['type']}) -> {pkg['path']}")

            # Crea una directory per i pacchetti esterni
            external_dir = temp_dir / "external_packages"
            external_dir.mkdir(exist_ok=True)

            # Copia il pacchetto sorgente
            target_pkg = external_dir / pkg['path'].name
            if not target_pkg.exists():
                shutil.copytree(pkg['path'], target_pkg,
                              ignore=shutil.ignore_patterns('__pycache__', '*.pyc', '.git'))

            # Crea un file di configurazione per ricreare i link editable
            self.create_editable_config(temp_dir, editable_packages)

    def create_editable_config(self, temp_dir, editable_packages):
        """Crea uno script per ricreare i link editable all'estrazione"""
        setup_script = temp_dir / "setup_editable_links.py"

        script_content = '''#!/usr/bin/env python3
"""
Setup script per ricreare i link editable dei pacchetti
"""
import os
import sys
from pathlib import Path

def setup_editable_links():
    """Ricrea i link editable nel virtual environment"""
    current_dir = Path(__file__).parent
    venv_dir = current_dir / ".venv"

    if not venv_dir.exists():
        print("Virtual environment non trovato")
        return

    # Determina il path di site-packages
    python_version = f"{sys.version_info.major}.{sys.version_info.minor}"
    site_packages = venv_dir / "lib" / f"python{python_version}" / "site-packages"
    site_packages.mkdir(parents=True, exist_ok=True)

    external_dir = current_dir / "external_packages"
    if not external_dir.exists():
        print("Nessun pacchetto esterno trovato")
        return

    # Crea i file .pth per ogni pacchetto
    for pkg_dir in external_dir.iterdir():
        if pkg_dir.is_dir():
            pth_file = site_packages / f"{pkg_dir.name}.pth"
            with open(pth_file, 'w') as f:
                f.write(str(pkg_dir.absolute()))
            print(f"✓ Link creato per {pkg_dir.name}")

    print("Setup completato!")

if __name__ == "__main__":
    setup_editable_links()
'''

        with open(setup_script, 'w') as f:
            f.write(script_content)
        setup_script.chmod(0o755)

    def copy_project_files(self, temp_dir):
        """Copia i file del progetto"""
        print("📁 Copiando i file del progetto...")

        # File e directory da includere
        include_items = [
            'src', 'tests', 'conf', 'scripts',
            'pyproject.toml', 'README.md', 'CHANGELOG.md',
            'library.json', 'uv.lock', 'build.py'
        ]

        # Directory da escludere
        exclude_dirs = {'__pycache__', '.git', '.pytest_cache', '.mypy_cache', 'dist'}

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

    def create_start_script(self, temp_dir):
        """Crea uno script di avvio per il bundle"""
        start_script = temp_dir / "run_lnsync.sh"

        script_content = '''#!/bin/bash
# Script per avviare lnSync dal bundle

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Attiva il virtual environment
source "$SCRIPT_DIR/.venv/bin/activate"

# Setup dei pacchetti editable se necessario
if [ -f "$SCRIPT_DIR/setup_editable_links.py" ]; then
    python "$SCRIPT_DIR/setup_editable_links.py"
fi

# Esegui l'applicazione
python -m src.lnsync.main "$@"
'''

        with open(start_script, 'w') as f:
            f.write(script_content)
        start_script.chmod(0o755)

        # Crea anche una versione Windows
        start_bat = temp_dir / "run_lnsync.bat"
        bat_content = '''@echo off
REM Script per avviare lnSync dal bundle (Windows)

set SCRIPT_DIR=%~dp0

REM Attiva il virtual environment
call "%SCRIPT_DIR%\\.venv\\Scripts\\activate.bat"

REM Setup dei pacchetti editable se necessario
if exist "%SCRIPT_DIR%\\setup_editable_links.py" (
    python "%SCRIPT_DIR%\\setup_editable_links.py"
)

REM Esegui l'applicazione
python -m src.lnsync.main %*
'''
        with open(start_bat, 'w') as f:
            f.write(bat_content)

    def create_install_script(self, temp_dir):
        """Crea uno script per installare il bundle"""
        install_script = temp_dir / "install_bundle.sh"

        script_content = '''#!/bin/bash
# Script per installare il bundle lnSync

echo "📦 Installazione di lnSync..."

# Crea un nuovo virtual environment
python3 -m venv .venv_bundle

# Attiva il virtual environment
source .venv_bundle/bin/activate

# Installa le dipendenze
pip install --upgrade pip
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
fi

echo "✅ Installazione completata!"
echo "Per eseguire lnSync: ./run_lnsync.sh"
'''

        with open(install_script, 'w') as f:
            f.write(script_content)
        install_script.chmod(0o755)

    def create_bundle(self):
        """Crea il bundle tar.gz"""
        print(f"🚀 Creazione bundle: {self.bundle_name}")

        # Crea directory temporanea
        temp_dir = self.root_dir / f"temp_bundle_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        temp_dir.mkdir(exist_ok=True)

        try:
            # Copia tutto nel bundle
            self.copy_venv(temp_dir)
            self.copy_project_files(temp_dir)
            self.handle_editable_packages(temp_dir)
            self.create_start_script(temp_dir)
            self.create_install_script(temp_dir)

            # Crea il file tar.gz
            self.dist_dir.mkdir(exist_ok=True)
            bundle_path = self.dist_dir / self.bundle_name

            with tarfile.open(bundle_path, "w:gz") as tar:
                tar.add(temp_dir, arcname="lnSync_bundle")

            # Calcola la dimensione
            size_mb = bundle_path.stat().st_size / (1024 * 1024)
            print(f"✅ Bundle creato: {bundle_path}")
            print(f"📊 Dimensione: {size_mb:.2f} MB")

            # Crea un file README per il bundle
            readme_path = self.dist_dir / "BUNDLE_README.txt"
            with open(readme_path, 'w') as f:
                f.write(f"""
Bundle lnSync
=============
Creato: {datetime.now()}
File: {self.bundle_name}

Utilizzo:
1. Estrai il bundle: tar -xzf {self.bundle_name}
2. Entra nella directory: cd lnSync_bundle
3. Esegui: ./run_lnsync.sh (Linux/macOS) o run_lnsync.bat (Windows)

Nota: Il bundle include il virtual environment e i pacchetti
editable sono configurati automaticamente all'avvio.
""")

        finally:
            # Pulisci directory temporanea
            shutil.rmtree(temp_dir, ignore_errors=True)

    def run(self):
        """Esegue il processo completo di building"""
        print("🔨 Avvio build bundle lnSync")
        print("=" * 50)

        if not self.check_requirements():
            sys.exit(1)

        self.create_bundle()
        print("\n✨ Build completata con successo!")

if __name__ == "__main__":
    builder = BundleBuilder()
    builder.run()