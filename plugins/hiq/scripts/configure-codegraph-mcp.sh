#!/usr/bin/env bash
# Thin wrapper → Python (cross-platform logic)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"
# portable: only project root; binary resolved at runtime via PATH / .hiq/tools
exec python3 "$SCRIPT_DIR/lib/codegraph_mcp.py" "$ROOT"
