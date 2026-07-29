#!/usr/bin/env bash
set -uo pipefail

RAW_INPUT="$(cat)"
PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python)"
else
  exit 0
fi

TMP_INPUT="$(mktemp 2>/dev/null || printf '%s/.hiq-claude-hook-stop-%s.json' "${TMPDIR:-/tmp}" "$$")"
cleanup() {
  rm -f "$TMP_INPUT"
}
trap cleanup EXIT
printf '%s' "$RAW_INPUT" >"$TMP_INPUT"

CWD="$($PYTHON_BIN - "$TMP_INPUT" <<'PY'
import json, sys
from pathlib import Path
raw = Path(sys.argv[1]).read_text(encoding='utf-8')
try:
    data = json.loads(raw)
except Exception:
    print('')
    raise SystemExit(0)
print(str(data.get('cwd') or '').strip())
PY
)"
[[ -n "$CWD" ]] || exit 0
[[ -f "$CWD/AGENTS.md" && -f "$CWD/.hiq/config.yaml" ]] || exit 0

HIQ_HOME_DIR="${HIQ_HOME_DIR:-$HOME/.hiq}"
HOOK_SH="$HIQ_HOME_DIR/scripts/hiq-hook.sh"
[[ -x "$HOOK_SH" || -f "$HOOK_SH" ]] || exit 0
bash "$HOOK_SH" "$CWD" pre-final --host=claude --adapter=claude >/dev/null 2>&1 || true
exit 0
