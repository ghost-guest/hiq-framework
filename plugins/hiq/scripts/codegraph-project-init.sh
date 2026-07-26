#!/usr/bin/env bash
# macOS / Linux non-interactive project CodeGraph init for hiq-init.
# Windows: use codegraph-project-init.cmd
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"
OS="$(bash "$SCRIPT_DIR/lib/detect-os.sh" 2>/dev/null || echo unknown)"

if [[ "$OS" == "windows" ]]; then
  echo "hiq-cg-init: Windows — dispatching to codegraph-project-init.cmd"
  if command -v cmd.exe >/dev/null 2>&1; then
    WIN_ROOT="$(cygpath -w "$ROOT" 2>/dev/null || echo "$ROOT")"
    WIN_CMD="$(cygpath -w "$SCRIPT_DIR/codegraph-project-init.cmd" 2>/dev/null || echo "$SCRIPT_DIR/codegraph-project-init.cmd")"
    cmd.exe /c "\"$WIN_CMD\" \"$WIN_ROOT\""
    exit $?
  fi
  echo "hiq-cg-init: cmd.exe not found" >&2
  exit 1
fi

echo "hiq-cg-init: os=$OS root=$ROOT"

# Resolve / install binary
BIN="$(python3 "$SCRIPT_DIR/lib/codegraph_resolve.py" 2>/dev/null || true)"
if [[ -z "${BIN:-}" ]]; then
  echo "hiq-cg-init: installing codegraph-rs for $OS..."
  bash "$SCRIPT_DIR/install-codegraph.sh"
  BIN="$(python3 "$SCRIPT_DIR/lib/codegraph_resolve.py" 2>/dev/null || true)"
fi
[[ -n "${BIN:-}" && -x "$BIN" ]] || { echo "hiq-cg-init: no codegraph binary" >&2; exit 1; }
echo "hiq-cg-init: binary=$BIN"

# init (TTY agent UI may fail — ignore if DB exists)
set +e
out="$("$BIN" init --path "$ROOT" 2>&1)"
rc=$?
set -e
printf '%s\n' "$out" | sed '/not a terminal/d;/IO error/d' || true
if printf '%s\n' "$out" | grep -q "not a terminal"; then
  echo "hiq-cg-init: note — skipped interactive agent UI; wiring MCP via HiQ"
fi

if [[ ! -d "$ROOT/.codegraph" ]]; then
  set +e
  "$BIN" init --no-index --path "$ROOT" >/dev/null 2>&1
  set -e
fi
if [[ ! -d "$ROOT/.codegraph" ]]; then
  echo "hiq-cg-init: FAILED — .codegraph not created (init rc=$rc)" >&2
  exit 1
fi

set +e
idx="$("$BIN" index --path "$ROOT" 2>&1)"
set -e
echo "$idx"
"$BIN" status --path "$ROOT" 2>&1 || true

# MCP non-interactive — portable paths only (no machine-absolute paths in configs)
python3 "$SCRIPT_DIR/lib/codegraph_mcp.py" "$ROOT"

echo "hiq-cg-init: done os=$OS root=$ROOT binary=$BIN (MCP configs are portable)"
exit 0
