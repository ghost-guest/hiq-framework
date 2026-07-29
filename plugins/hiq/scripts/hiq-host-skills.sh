#!/usr/bin/env bash
set -euo pipefail

ROOT="."
if [[ $# -gt 0 && "${1:-}" != --* ]]; then
  ROOT="$1"
  shift
fi
ROOT="$(cd "$ROOT" && pwd)"

HOST="auto"
JSON_MODE=false
for arg in "$@"; do
  case "$arg" in
    --host=*) HOST="${arg#--host=}" ;;
    --json) JSON_MODE=true ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

HOME_DIR="${HOME:-}"
CLAUDE_SKILLS="${CLAUDE_SKILLS:-$HOME_DIR/.claude/skills}"
CODEX_SKILLS="${CODEX_SKILLS:-$HOME_DIR/.codex/skills}"
PI_SKILLS="${PI_SKILLS:-$HOME_DIR/.pi/agent/skills}"
LIVEAGENT_SKILLS="${LIVEAGENT_SKILLS:-$HOME_DIR/.liveagent/skills}"
PROJECT_SKILLS="$ROOT/.agents/skills"

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python)"
fi
if [[ -z "$PYTHON_BIN" ]]; then
  echo "hiq-host-skills: python3/python is required" >&2
  exit 1
fi

CURRENT="$ROOT/.hiq/current-change.json"
if [[ "$HOST" == auto ]]; then
  if [[ -n "${HIQ_HOST_TARGET:-}" ]]; then
    HOST="$HIQ_HOST_TARGET"
  elif [[ -f "$CURRENT" ]]; then
    HOST="$($PYTHON_BIN - "$CURRENT" <<'PY'
import json, sys
from pathlib import Path
path = Path(sys.argv[1])
try:
    data = json.loads(path.read_text(encoding='utf-8'))
except Exception:
    print('unknown')
    raise SystemExit(0)
print((data.get('hostTarget') or 'unknown').strip() or 'unknown')
PY
)"
  else
    HOST="unknown"
  fi
fi

SKILL_ROOT=""
case "$HOST" in
  claude) SKILL_ROOT="$CLAUDE_SKILLS" ;;
  codex) SKILL_ROOT="$CODEX_SKILLS" ;;
  pi) SKILL_ROOT="$PI_SKILLS" ;;
  liveagent) SKILL_ROOT="$LIVEAGENT_SKILLS" ;;
  project) SKILL_ROOT="$PROJECT_SKILLS" ;;
  *) SKILL_ROOT="" ;;
esac

"$PYTHON_BIN" - "$HOST" "$SKILL_ROOT" "$JSON_MODE" <<'PY'
import json, sys
from pathlib import Path
host, root_value, json_mode = sys.argv[1:4]
root = Path(root_value).expanduser() if root_value else None
skills = []
exists = False
if root and root.exists():
    exists = True
    for entry in sorted(root.iterdir(), key=lambda p: p.name.lower()):
        if not entry.is_dir():
            continue
        skills.append({
            'name': entry.name,
            'path': str(entry),
            'hasSkillFile': (entry / 'SKILL.md').exists() or (entry / 'README.md').exists(),
        })
result = {
    'host': host,
    'skillRoot': str(root) if root else None,
    'rootExists': exists,
    'count': len(skills),
    'skills': skills,
}
if json_mode == 'true':
    print(json.dumps(result, indent=2, ensure_ascii=False))
else:
    print(f"host={host}")
    print(f"skill_root={result['skillRoot'] or 'none'}")
    print(f"root_exists={'true' if exists else 'false'}")
    print(f"count={len(skills)}")
    for skill in skills:
        print(f"skill={skill['name']}")
PY
