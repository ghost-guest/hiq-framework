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

TMP_INPUT="$(mktemp 2>/dev/null || printf '%s/.hiq-claude-hook-%s.json' "${TMPDIR:-/tmp}" "$$")"
cleanup() {
  rm -f "$TMP_INPUT"
}
trap cleanup EXIT
printf '%s' "$RAW_INPUT" >"$TMP_INPUT"

PARSED="$($PYTHON_BIN - "$TMP_INPUT" <<'PY'
import json, sys
from pathlib import Path
raw = Path(sys.argv[1]).read_text(encoding='utf-8')
try:
    data = json.loads(raw)
except Exception:
    print('')
    print('')
    raise SystemExit(0)
prompt = str(data.get('prompt') or '').replace('\n', ' ').strip()[:400]
cwd = str(data.get('cwd') or '').strip()
print(cwd)
print(prompt)
PY
)"
CWD="$(printf '%s\n' "$PARSED" | sed -n '1p')"
PROMPT="$(printf '%s\n' "$PARSED" | sed -n '2p')"
[[ -n "$CWD" ]] || exit 0
[[ -f "$CWD/AGENTS.md" && -f "$CWD/.hiq/config.yaml" ]] || exit 0

HIQ_HOME_DIR="${HIQ_HOME_DIR:-$HOME/.hiq}"
HOOK_SH="$HIQ_HOME_DIR/scripts/hiq-hook.sh"
ACTIVATE_SH="$HIQ_HOME_DIR/scripts/hiq-activate.sh"
[[ -x "$HOOK_SH" || -f "$HOOK_SH" ]] || exit 0
[[ -x "$ACTIVATE_SH" || -f "$ACTIVATE_SH" ]] || exit 0

bash "$HOOK_SH" "$CWD" pre-session --host=claude --adapter=claude >/dev/null 2>&1 || true
bash "$ACTIVATE_SH" "$CWD" --if-needed --mode=auto --goal-title="$PROMPT" --goal-now="$PROMPT" --acceptance="$PROMPT" --owner=hiq-grill --phase=grill --next-skill=hiq-grill --next-step="clarify scope, confirm acceptance target, and choose the truthful next owner lane" --host=claude --hook-adapter=claude --reason="Claude hook loaded the HiQ auto entry contract for this project turn" >/dev/null 2>&1 || true
exit 0
