#!/usr/bin/env bash
# HiQ-managed codegraph-rs launcher (macOS/Linux). Windows: codegraph.cmd
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(bash "$SCRIPT_DIR/lib/detect-os.sh" 2>/dev/null || echo unknown)"
if [[ "$OS" == "windows" ]]; then
  exec cmd.exe /c "$(cygpath -w "$SCRIPT_DIR/codegraph.cmd" 2>/dev/null || echo "$SCRIPT_DIR/codegraph.cmd")" "$@"
fi
BIN="$(python3 "$SCRIPT_DIR/lib/codegraph_resolve.py" 2>/dev/null || true)"
if [[ -z "${BIN:-}" ]]; then
  bash "$SCRIPT_DIR/install-codegraph.sh"
  BIN="$(python3 "$SCRIPT_DIR/lib/codegraph_resolve.py" 2>/dev/null || true)"
fi
[[ -n "${BIN:-}" && -x "$BIN" ]] || { echo "hiq-codegraph: missing binary" >&2; exit 127; }
exec "$BIN" "$@"
