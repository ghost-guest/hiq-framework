#!/usr/bin/env bash
set -euo pipefail

ROOT="."
if [[ $# -gt 0 && "${1:-}" != --* ]]; then
  ROOT="$1"
  shift
fi
ROOT="$(cd "$ROOT" && pwd)"
EVENT="${1:-}"
if [[ -z "$EVENT" || "$EVENT" == --* ]]; then
  echo "usage: hiq-hook.sh [project-root] pre-session|pre-tool|post-tool|pre-final|checkpoint|status [--host NAME] [--adapter NAME] [--tool NAME] [--context-pressure LEVEL] [--json]" >&2
  exit 2
fi
shift || true

HOST="generic"
ADAPTER="generic"
TOOL=""
CONTEXT_PRESSURE="unknown"
JSON_MODE=false
for arg in "$@"; do
  case "$arg" in
    --host=*) HOST="${arg#--host=}" ;;
    --adapter=*) ADAPTER="${arg#--adapter=}" ;;
    --tool=*) TOOL="${arg#--tool=}" ;;
    --context-pressure=*) CONTEXT_PRESSURE="${arg#--context-pressure=}" ;;
    --json) JSON_MODE=true ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

case "$EVENT" in
  pre-session|pre-tool|post-tool|pre-final|checkpoint|status) ;;
  *) echo "unknown hook event: $EVENT" >&2; exit 2 ;;
esac

HIQ="$ROOT/.hiq"
CURRENT="$HIQ/current-change.json"
SESSION="$HIQ/session.md"
RUN_DIR="$HIQ/hooks/runs"
mkdir -p "$RUN_DIR" "$HIQ/hooks/adapters"
STAMP="$(date +%Y-%m-%dT%H:%M:%S%z)"
RUN_STAMP="$(date +%Y%m%d-%H%M%S)"
RUN_REL=".hiq/hooks/runs/$RUN_STAMP-$EVENT.json"
RUN_PATH="$ROOT/${RUN_REL#./}"

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python)"
fi
if [[ -z "$PYTHON_BIN" ]]; then
  echo "hiq-hook: python3/python is required for POSIX hook state updates" >&2
  exit 1
fi

required_actions='[]'
allow=true
if [[ "$EVENT" == checkpoint || "$CONTEXT_PRESSURE" == high || "$CONTEXT_PRESSURE" == critical ]]; then
  required_actions='["write-context-checkpoint"]'
fi

cat >"$RUN_PATH" <<EOF
{
  "framework": "hiq",
  "schema": 1,
  "event": "$EVENT",
  "host": "$HOST",
  "adapter": "$ADAPTER",
  "tool": "$TOOL",
  "contextPressure": "$CONTEXT_PRESSURE",
  "cwd": "$ROOT",
  "allow": $allow,
  "requiredActions": $required_actions,
  "ownerSkill": "hiq-auto",
  "status": "pass",
  "createdAt": "$STAMP"
}
EOF

if [[ "$EVENT" != status ]]; then
  "$PYTHON_BIN" - "$CURRENT" "$SESSION" "$RUN_REL" "$EVENT" "$HOST" "$ADAPTER" "$STAMP" <<'PY'
import json, re, sys
from pathlib import Path
current_path = Path(sys.argv[1])
session_path = Path(sys.argv[2])
hook_state_path = current_path.parent / 'hooks' / 'hook-state.json'
run_rel, event, host, adapter, stamp = sys.argv[3:8]
if current_path.exists():
    data = json.loads(current_path.read_text(encoding='utf-8'))
else:
    data = {"framework": "hiq", "schema": 2}
data.update({
    "hostTarget": host,
    "hostAutomationLevel": "turn-scoped",
    "hostAutomationEvidence": run_rel,
    "hookProtocolVersion": 1,
    "hookCoreStatus": "available",
    "hookAdapter": adapter,
    "hookLastEvent": event,
    "hookLastRunPath": run_rel,
    "hookLastRunAt": stamp,
    "hookLastRunStatus": "pass",
    "updatedAt": stamp,
})
current_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding='utf-8')
hook_state = {
    "framework": "hiq",
    "schema": 1,
    "protocolVersion": 1,
    "coreStatus": "available",
    "adapter": adapter,
    "host": host,
    "automationLevel": "turn-scoped",
    "evidenceRoot": ".hiq/hooks/runs",
    "lastEvent": event,
    "lastRunPath": run_rel,
    "lastRunAt": stamp,
    "lastRunStatus": "pass",
}
hook_state_path.write_text(json.dumps(hook_state, indent=2, ensure_ascii=False) + "\n", encoding='utf-8')

if session_path.exists():
    text = session_path.read_text(encoding='utf-8')
    replacements = {
        "updated": stamp,
        "host_target": host,
        "host_automation_level": "turn-scoped",
        "host_automation_evidence": f"`{run_rel}`",
        "hook_protocol_version": "1",
        "hook_core_status": "available",
        "hook_adapter": adapter,
        "hook_last_event": event,
        "hook_last_run": f"`{run_rel}`",
        "hook_last_status": "pass",
    }
    for key, value in replacements.items():
        pattern = re.compile(rf"^- \*\*{re.escape(key)}\*\*:.*$", re.MULTILINE)
        line = f"- **{key}**: {value}"
        if pattern.search(text):
            text = pattern.sub(line, text)
        elif key.startswith("hook_"):
            marker = "- **host_automation_evidence**:"
            lines = text.splitlines()
            for i, existing in enumerate(lines):
                if existing.startswith(marker):
                    lines.insert(i + 1, line)
                    text = "\n".join(lines) + "\n"
                    break
    session_path.write_text(text, encoding='utf-8')
PY
fi

if $JSON_MODE; then
  cat "$RUN_PATH"
else
  echo "hook.event=$EVENT"
  echo "hook.host=$HOST"
  echo "hook.adapter=$ADAPTER"
  echo "hook.run=$RUN_REL"
  echo "hook.status=pass"
  echo "allow=$allow"
fi
