#!/usr/bin/env bash

#!/usr/bin/env bash

set -euo pipefail

############################################################
# usage
############################################################

: <<'USAGE'
Create modern Python project

Usage:
    init_uv_project.sh 3.14.5 my_project

Example:
    init_uv_project.sh 3.14.5 git_commit
USAGE

############################################################
# config
############################################################

SUCCESS='✅'
ERROR='❌'
INFO='ℹ️'

############################################################
# args
############################################################

PYTHON_VERSION="${1:-}"
PROJECT_NAME="${2:-}"

if [[ -z "$PYTHON_VERSION" ]]; then
    echo "$ERROR Missing python version"
    exit 1
fi

if [[ -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME="$(basename "$PWD")"
    echo "$INFO Using current dir name: $PROJECT_NAME"
else
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"
fi

############################################################
# normalize names
############################################################

PACKAGE_NAME="$(echo "$PROJECT_NAME" | tr '-' '_' | tr '[:upper:]' '[:lower:]')"

echo ""
echo "$INFO Project:        $PROJECT_NAME"
echo "$INFO Package:        $PACKAGE_NAME"
echo "$INFO Python version: $PYTHON_VERSION"
echo ""

############################################################
# checks
############################################################

command -v uv >/dev/null || {
    echo "$ERROR uv not installed"
    exit 1
}

############################################################
# pyenv
############################################################

if command -v pyenv >/dev/null; then
    pyenv local "$PYTHON_VERSION"
else
    echo "$INFO pyenv not found, skipping"
fi

############################################################
# venv
############################################################

if [[ ! -d .venv ]]; then
    uv venv
fi

############################################################
# structure
############################################################

mkdir -p \
    "src/$PACKAGE_NAME" \
    tests \
    scripts

############################################################
# package files
############################################################

cat > "src/$PACKAGE_NAME/__init__.py" <<EOF
__version__ = "0.1.0"
EOF

cat > "src/$PACKAGE_NAME/main.py" <<EOF
def main():
    print("Hello from $PACKAGE_NAME")


if __name__ == "__main__":
    main()
EOF

############################################################
# tests
############################################################

cat > tests/test_main.py <<EOF
from $PACKAGE_NAME.main import main


def test_main():
    assert main() is None
EOF

############################################################
# pyproject.toml
############################################################

cat > pyproject.toml <<EOF
[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"

[project]
name = "$PROJECT_NAME"
version = "0.1.0"
description = ""
readme = "README.md"
requires-python = ">=$PYTHON_VERSION"

dependencies = [
    "pyyaml>=6.0.3",
]

[project.optional-dependencies]
dev = [
    "pytest",
    "ruff",
]

[project.scripts]
$PROJECT_NAME = "$PACKAGE_NAME.main:main"

[tool.setuptools.packages.find]
where = ["src"]

[tool.uv.sources]
pylnlib = { path = "../pyLnLib", editable = true }

[tool.ruff]
line-length = 100
EOF

############################################################
# README
############################################################

cat > README.md <<EOF
# $PROJECT_NAME
EOF

############################################################
# gitignore
############################################################

cat > .gitignore <<EOF
.venv/
__pycache__/
*.pyc
*.pyo
*.egg-info/
dist/
build/
.pytest_cache/
.ruff_cache/
EOF

############################################################
# direnv
############################################################

cat > .envrc <<EOF
source .venv/bin/activate
EOF

############################################################
# install dependencies
############################################################

uv sync

############################################################
# optional local pyLnLib
############################################################

if [[ -d ../pyLnLib ]]; then
    echo "$INFO Adding local pyLnLib"
    uv add ../pyLnLib
fi

############################################################
# done
############################################################

echo ""
echo "$SUCCESS Project ready"
echo ""
echo "Next steps:"
echo ""
echo "  direnv allow"
echo "  uv run $PROJECT_NAME"
echo ""