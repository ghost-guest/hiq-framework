#!/usr/bin/env bash
set -euo pipefail

ROOT="."
if [[ $# -gt 0 && "${1:-}" != --* ]]; then
  ROOT="$1"
  shift
fi
ROOT="$(cd "$ROOT" && pwd)"
JSON_MODE=false
for arg in "$@"; do
  case "$arg" in
    --json) JSON_MODE=true ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

HIQ="$ROOT/.hiq"
SESSION="$HIQ/session.md"
CURRENT="$HIQ/current-change.json"

md_field() {
  local key="$1"
  local file="$2"
  [[ -f "$file" ]] || return 0
  sed -n "s/^- \*\*$key\*\*: //p" "$file" | head -n1 | sed 's/^`//; s/`$//'
}

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python)"
fi

json_raw() {
  local key="$1"
  local file="$2"
  [[ -f "$file" ]] || return 0
  if [[ -n "$PYTHON_BIN" ]]; then
    "$PYTHON_BIN" - "$key" "$file" <<'PY'
import json, sys
data = json.load(open(sys.argv[2], encoding='utf-8'))
key = sys.argv[1]
if key not in data:
    raise SystemExit(1)
value = data[key]
if value is None:
    print('null')
elif isinstance(value, bool):
    print(str(value).lower())
elif isinstance(value, (dict, list)):
    print(json.dumps(value, ensure_ascii=False, separators=(',', ':')))
else:
    print(json.dumps(value, ensure_ascii=False))
PY
    return $?
  fi
  sed -n "s/^[[:space:]]*\"$key\"[[:space:]]*:[[:space:]]*//p" "$file" | head -n1 | sed 's/[[:space:]]*,[[:space:]]*$//'
}

json_field() {
  local raw
  raw="$(json_raw "$1" "$2" 2>/dev/null || true)"
  if [[ "$raw" == \"*\" ]]; then
    raw="${raw#\"}"
    raw="${raw%\"}"
    printf '%s\n' "$raw" | sed 's/\\"/"/g; s/\\\\/\\/g'
  else
    printf '%s\n' "$raw"
  fi
}

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g'
}

normalize_none() {
  case "${1:-}" in ""|none|null) printf '%s' none ;; *) printf '%s' "$1" ;; esac
}

entry_skill="$(json_field entrySkill "$CURRENT")"
entry_mode="$(json_field entryMode "$CURRENT")"
host_target="$(json_field hostTarget "$CURRENT")"
host_level="$(json_field hostAutomationLevel "$CURRENT")"
auto_status="$(json_field autoStatus "$CURRENT")"
auto_owner="$(json_field autoOwnerSkill "$CURRENT")"
auto_reason="$(json_field autoReason "$CURRENT")"
manual_override="$(json_field manualOverride "$CURRENT")"
active_change="$(json_field activeChange "$CURRENT")"
phase="$(json_field phase "$CURRENT")"
owner_skill="$(json_field ownerSkill "$CURRENT")"
next_skill="$(json_field nextSkill "$CURRENT")"
next_step="$(json_field nextStep "$CURRENT")"
goal_now="$(json_field goalNow "$CURRENT")"
state_status="$(json_field stateStatus "$CURRENT")"
content_revision="$(json_field contentRevision "$CURRENT")"
review_status="$(json_field reviewStatus "$CURRENT")"
review_path="$(json_field reviewPath "$CURRENT")"
eval_applicability="$(json_field evalApplicability "$CURRENT")"
eval_status="$(json_field evalStatus "$CURRENT")"
checkpoint_required="$(json_field checkpointRequired "$CURRENT")"
checkpoint_reason="$(json_field checkpointReason "$CURRENT")"
checkpoint="$(json_field latestCheckpoint "$CURRENT")"
verify_status="$(json_field verifyStatus "$CURRENT")"
updated="$(json_field updatedAt "$CURRENT")"

active_change="$(normalize_none "$active_change")"
review_path="$(normalize_none "$review_path")"
checkpoint="$(normalize_none "$checkpoint")"
[[ -n "$entry_skill" ]] || entry_skill="$(md_field entry_skill "$SESSION")"
[[ -n "$entry_mode" ]] || entry_mode="$(md_field entry_mode "$SESSION")"
[[ -n "$auto_status" ]] || auto_status="$(md_field auto_status "$SESSION")"
[[ -n "$auto_owner" ]] || auto_owner="$(md_field auto_owner "$SESSION")"
[[ -n "$auto_reason" ]] || auto_reason="$(md_field auto_reason "$SESSION")"
[[ -n "$manual_override" ]] || manual_override="$(md_field manual_override "$SESSION")"
[[ -n "$active_change" ]] || active_change="$(md_field active_change "$SESSION")"
[[ -n "$phase" ]] || phase="$(md_field phase "$SESSION")"
[[ -n "$next_skill" ]] || next_skill="$(md_field next_skill "$SESSION")"
[[ -n "$next_step" ]] || next_step="$(md_field next_step "$SESSION")"
[[ -n "$goal_now" ]] || goal_now="$(md_field goal_now "$SESSION")"
[[ -n "$checkpoint" ]] || checkpoint="$(md_field latest_checkpoint "$SESSION")"

pointer_status=ok
case "$phase" in
  idle) expected_owner=hiq-session ;;
  init) expected_owner=hiq-init ;;
  install) expected_owner=hiq-install ;;
  grill) expected_owner=hiq-grill ;;
  implement) expected_owner=hiq-implement ;;
  debug) expected_owner=hiq-debug ;;
  review) expected_owner=hiq-review ;;
  evolve) expected_owner=hiq-evolve ;;
  knowledge) expected_owner=hiq-knowledge ;;
  skill) expected_owner=hiq-skill ;;
  *) expected_owner=""; pointer_status=partial ;;
esac
if [[ -n "$expected_owner" && "$owner_skill" != "$expected_owner" ]]; then pointer_status=partial; fi
if [[ "$(normalize_none "$manual_override")" == none && "$auto_owner" != "$owner_skill" ]]; then pointer_status=partial; fi
if [[ -n "$phase" && "$(md_field phase "$SESSION")" != "$phase" ]]; then pointer_status=partial; fi
if [[ -n "$next_skill" && "$(md_field next_skill "$SESSION")" != "$next_skill" ]]; then pointer_status=partial; fi
if [[ "$(normalize_none "$checkpoint")" != none ]]; then
  if [[ ! -f "$ROOT/${checkpoint#./}" ]]; then pointer_status=partial; fi
fi

if $JSON_MODE; then
  printf '{\n'
  printf '  "root": "%s",\n' "$(json_escape "$ROOT")"
  printf '  "hiq": "%s",\n' "$(json_escape "$HIQ")"
  printf '  "sessionExists": %s,\n' "$( [[ -f "$SESSION" ]] && echo true || echo false )"
  printf '  "currentChangeExists": %s,\n' "$( [[ -f "$CURRENT" ]] && echo true || echo false )"
  printf '  "entrySkill": "%s",\n' "$(json_escape "$entry_skill")"
  printf '  "entryMode": "%s",\n' "$(json_escape "$entry_mode")"
  printf '  "hostTarget": "%s",\n' "$(json_escape "$host_target")"
  printf '  "hostAutomationLevel": "%s",\n' "$(json_escape "$host_level")"
  printf '  "autoStatus": "%s",\n' "$(json_escape "$auto_status")"
  printf '  "autoOwnerSkill": "%s",\n' "$(json_escape "$auto_owner")"
  printf '  "autoReason": "%s",\n' "$(json_escape "$auto_reason")"
  printf '  "manualOverride": "%s",\n' "$(json_escape "$manual_override")"
  printf '  "activeChange": "%s",\n' "$(json_escape "$active_change")"
  printf '  "stateStatus": "%s",\n' "$(json_escape "$state_status")"
  printf '  "phase": "%s",\n' "$(json_escape "$phase")"
  printf '  "contentRevision": "%s",\n' "$(json_escape "$content_revision")"
  printf '  "ownerSkill": "%s",\n' "$(json_escape "$owner_skill")"
  printf '  "nextSkill": "%s",\n' "$(json_escape "$next_skill")"
  printf '  "nextStep": "%s",\n' "$(json_escape "$next_step")"
  printf '  "goalNow": "%s",\n' "$(json_escape "$goal_now")"
  printf '  "reviewStatus": "%s",\n' "$(json_escape "$review_status")"
  printf '  "reviewPath": "%s",\n' "$(json_escape "$review_path")"
  printf '  "evalApplicability": "%s",\n' "$(json_escape "$eval_applicability")"
  printf '  "evalStatus": "%s",\n' "$(json_escape "$eval_status")"
  printf '  "checkpointRequired": %s,\n' "${checkpoint_required:-false}"
  printf '  "checkpointReason": "%s",\n' "$(json_escape "$checkpoint_reason")"
  printf '  "latestCheckpoint": "%s",\n' "$(json_escape "$checkpoint")"
  printf '  "verifyStatus": "%s",\n' "$(json_escape "$verify_status")"
  printf '  "updatedAt": "%s",\n' "$(json_escape "$updated")"
  printf '  "pointerStatus": "%s"\n' "$pointer_status"
  printf '}\n'
  exit 0
fi

echo "hiq_root=$ROOT"
echo "session=$([[ -f "$SESSION" ]] && echo ok || echo missing)"
echo "current_change=$([[ -f "$CURRENT" ]] && echo ok || echo missing)"
echo "entry_skill=${entry_skill:-unknown}"
echo "entry_mode=${entry_mode:-unknown}"
echo "host_target=${host_target:-unknown}"
echo "host_automation_level=${host_level:-unknown}"
echo "auto_status=${auto_status:-unknown}"
echo "auto_owner=${auto_owner:-unknown}"
echo "auto_reason=${auto_reason:-}"
echo "manual_override=${manual_override:-none}"
echo "active_change=${active_change:-none}"
echo "state_status=${state_status:-unknown}"
echo "phase=${phase:-unknown}"
echo "content_revision=${content_revision:-unknown}"
echo "owner_skill=${owner_skill:-unknown}"
echo "next_skill=${next_skill:-unknown}"
echo "next_step=${next_step:-}"
echo "goal_now=${goal_now:-}"
echo "review_status=${review_status:-unknown}"
echo "review_path=${review_path:-none}"
echo "eval_applicability=${eval_applicability:-unknown}"
echo "eval_status=${eval_status:-unknown}"
echo "checkpoint_required=${checkpoint_required:-false}"
echo "checkpoint_reason=${checkpoint_reason:-none}"
echo "checkpoint=${checkpoint:-none}"
echo "verify_status=${verify_status:-unknown}"
echo "updated=${updated:-unknown}"
echo "pointer_status=$pointer_status"
