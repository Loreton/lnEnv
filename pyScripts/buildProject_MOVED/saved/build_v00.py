#!/usr/bin/env python3
"""
Build script for lnSync - creates a portable bundle with embedded venv
Requires: .venv to be already created with 'uv venv'
"""

import os
import sys
import shutil
import subprocess
from pathlib import Path
from typing import Optional

class BuildManager:
    def __init__(self, project_root: Optional[Path] = None):
        if project_root:
            self.project_root = Path(project_root).absolute()
        else:
            # Usa la directory dello script come punto di partenza
            script_dir = Path(__file__).parent.absolute()
            
            # Cerca pyproject.toml nella directory dello script (no risalita)
            if (script_dir / "pyproject.toml").exists():
                self.project_root = script_dir
            else:
                # Se non trovato, usa la directory corrente
                self.project_root = Path.cwd()
        
        if not (self.project_root / "pyproject.toml").exists():
            print(f"❌ Error: pyproject.toml not found in {self.project_root}")
            sys.exit(1)
        
        # Check if .venv exists
        self.venv_dir = self.project_root / ".venv"
        if not self.venv_dir.exists():
            print(f"❌ Error: .venv not found in {self.project_root}")
            print(f"\n📝 Please create it first with:")
            print(f"   uv venv")
            print(f"   uv sync")
            sys.exit(1)
        
        self.dist_dir = self.project_root / "dist"
        self.build_dir = self.project_root / ".build"
        
        print(f"📁 Project root: {self.project_root}")
        print(f"🐍 Using venv: {self.venv_dir}\n")
        
    def clean(self):
        """Clean previous builds"""
        print("🧹 Cleaning previous builds...")
        for dir_to_remove in [self.dist_dir, self.build_dir]:
            if dir_to_remove.exists():
                shutil.rmtree(dir_to_remove)
                print(f"   Removed: {dir_to_remove}")
        print()
    
    def build_wheel(self):
        """Build wheel package"""
        print("📦 Building wheel...")
        result = subprocess.run(
            ["uv", "build", "--wheel"],
            cwd=self.project_root,
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            print(f"❌ Wheel build failed:\n{result.stderr}")
            sys.exit(1)
        print("   ✅ Wheel built successfully")
        print()
    
    def build_sdist(self):
        """Build source distribution"""
        print("📦 Building source distribution...")
        result = subprocess.run(
            ["uv", "build", "--sdist"],
            cwd=self.project_root,
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            print(f"❌ SDist build failed:\n{result.stderr}")
            sys.exit(1)
        print("   ✅ Source distribution built successfully")
        print()
    
    def create_bundle(self):
        """Create portable bundle with venv"""
        print("📦 Creating portable bundle...")
        
        bundle_name = "lnSync_bundle"
        bundle_dir = self.build_dir / bundle_name
        
        # Remove if exists
        if bundle_dir.exists():
            shutil.rmtree(bundle_dir)
        
        bundle_dir.mkdir(parents=True, exist_ok=True)
        
        # Copy existing venv to bundle (preserve symlinks)
        venv_bundle_dir = bundle_dir / "venv"
        print(f"   Copying venv to bundle...")
        shutil.copytree(
            self.venv_dir,
            venv_bundle_dir,
            symlinks=True  # Preserve symlinks
        )
        
        # Copy project code
        print(f"   Copying source code...")
        src_dir = self.project_root / "src"
        if src_dir.exists():
            shutil.copytree(
                src_dir,
                bundle_dir / "src"
            )
        
        # Copy config
        conf_dir = self.project_root / "conf"
        if conf_dir.exists():
            shutil.copytree(
                conf_dir,
                bundle_dir / "conf"
            )
        
        # Create run script with PYTHONPATH
        run_script = bundle_dir / "run.sh"
        run_script.write_text("""#!/bin/bash
# Portable lnSync runner
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/venv/bin/activate"
export PYTHONPATH="$SCRIPT_DIR/src:$PYTHONPATH"
exec python -m lnsync "$@"
""")
        run_script.chmod(0o755)
        
        # Create tarball
        bundle_tar = self.dist_dir / f"{bundle_name}.tgz"
        self.dist_dir.mkdir(exist_ok=True)
        
        print(f"   Creating {bundle_tar}...")
        shutil.make_archive(
            str(bundle_tar.with_suffix('')),
            'gztar',
            self.build_dir,
            bundle_name
        )
        
        print("   ✅ Bundle created successfully")
        print()
    
    def print_summary(self):
        """Print build summary"""
        print("=" * 60)
        print("✅ BUILD COMPLETED")
        print("=" * 60)
        print(f"\nArtifacts in {self.dist_dir}:")
        
        if self.dist_dir.exists():
            for item in sorted(self.dist_dir.iterdir()):
                size = item.stat().st_size / (1024*1024)  # MB
                print(f"  📦 {item.name} ({size:.1f} MB)")
        
        print("\n📋 Usage:")
        print("  Local: uv run lnsync [options]")
        print("  Raspberry (extract bundle):")
        print("    tar xzf lnSync_bundle.tgz")
        print("    ./lnSync_bundle/run.sh [options]")
        print()
    
    def build_all(self):
        """Build all artifacts"""
        print("\n" + "=" * 60)
        print("🚀 LNSYNC BUILD PROCESS")
        print("=" * 60 + "\n")
        
        self.clean()
        self.build_wheel()
        self.build_sdist()
        self.create_bundle()
        self.print_summary()

def main():
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Build lnSync project (requires .venv to exist)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Setup:
  uv venv                      # Create .venv with current Python
  uv sync                      # Install dependencies

Examples:
  python build.py              # Build wheel, sdist, and bundle
  python build.py --bundle     # Only build portable bundle
  python build.py --wheel      # Only build wheel
  python build.py -p /path     # Specify project root
  python build.py --clean      # Clean builds
        """
    )
    
    parser.add_argument("-p", "--project", help="Project root directory")
    parser.add_argument("--clean", action="store_true", help="Clean builds only")
    parser.add_argument("--wheel", action="store_true", help="Build only wheel")
    parser.add_argument("--sdist", action="store_true", help="Build only source dist")
    parser.add_argument("--bundle", action="store_true", help="Build only portable bundle")
    
    args = parser.parse_args()
    
    builder = BuildManager(project_root=args.project)
    
    if args.clean:
        builder.clean()
        return
    
    # If specific build requested
    if args.wheel:
        builder.build_wheel()
    elif args.sdist:
        builder.build_sdist()
    elif args.bundle:
        builder.create_bundle()
        builder.print_summary()
    else:
        # Build everything
        builder.build_all()

if __name__ == "__main__":
    main()
