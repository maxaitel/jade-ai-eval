#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

python3 -m venv --clear .venv
.venv/bin/python -m pip install --upgrade pip

echo "Created .venv for evaluator tooling."
echo "Note: JADE (Jade Software language) is proprietary and not installable via pip."
echo "Use COMPILE_CMD to call your local JADE compiler/build tooling."

