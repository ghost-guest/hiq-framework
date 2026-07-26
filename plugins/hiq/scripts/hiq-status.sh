#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"
HIQ="$ROOT/.hiq"
SESSION="$HIQ/session.md"
CURRENT="$HIQ/current-change.json"
JSON_MODE="${2:-}"

md_field() {
  local key="$1"
  local file="$2"
  if [[ ! -f "$file" ]]; then
    return 0
  fi
  sed -n "s/^- \*\*$key\*\*: //p" "$file" | head -n1 | sed 's/^`//; s/`$//'
}

json_field() {
  local key="$1"
  local file="$2"
  if [[ ! -f "$file" ]]; then
    return 0
  fi
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$file" | head -n1
}

entry_skill="$(md_field entry_skill "$SESSION")"
entry_mode="$(md_field entry_mode "$SESSION")"
auto_status="$(md_field auto_status "$SESSION")"
auto_owner="$(md_field auto_owner "$SESSION")"
auto_reason="$(md_field auto_reason "$SESSION")"
manual_override="$(md_field manual_override "$SESSION")"
active_change="$(md_field active_change "$SESSION")"
phase="$(md_field phase "$SESSION")"
next_skill="$(md_field next_skill "$SESSION")"
next_step="$(md_field next_step "$SESSION")"
goal_now="$(md_field goal_now "$SESSION")"
checkpoint="$(md_field latest_checkpoint "$SESSION")"
updated="$(md_field updated "$SESSION")"
entry_skill_json="$(json_field entrySkill "$CURRENT")"
entry_mode_json="$(json_field entryMode "$CURRENT")"
auto_status_json="$(json_field autoStatus "$CURRENT")"
auto_owner_json="$(json_field autoOwnerSkill "$CURRENT")"
auto_reason_json="$(json_field autoReason "$CURRENT")"
manual_override_json="$(json_field manualOverride "$CURRENT")"
owner_skill="$(json_field ownerSkill "$CURRENT")"
current_phase="$(json_field phase "$CURRENT")"

if [[ "$JSON_MODE" == "--json" ]]; then
  printf '{\n'
  printf '  "root": "%s",\n' "$ROOT"
  printf '  "hiq": "%s",\n' "$HIQ"
  printf '  "sessionExists": %s,\n' "$( [[ -f "$SESSION" ]] && echo true || echo false )"
  printf '  "currentChangeExists": %s,\n' "$( [[ -f "$CURRENT" ]] && echo true || echo false )"
  printf '  "entrySkill": "%s",\n' "${entry_skill_json:-${entry_skill:-}}"
  printf '  "entryMode": "%s",\n' "${entry_mode_json:-${entry_mode:-}}"
  printf '  "autoStatus": "%s",\n' "${auto_status_json:-${auto_status:-}}"
  printf '  "autoOwnerSkill": "%s",\n' "${auto_owner_json:-${auto_owner:-}}"
  printf '  "autoReason": "%s",\n' "${auto_reason_json:-${auto_reason:-}}"
  printf '  "manualOverride": "%s",\n' "${manual_override_json:-${manual_override:-}}"
  printf '  "activeChange": "%s",\n' "${active_change:-}"
  printf '  "phase": "%s",\n' "${phase:-}"
  printf '  "ownerSkill": "%s",\n' "${owner_skill:-}"
  printf '  "currentPhase": "%s",\n' "${current_phase:-}"
  printf '  "nextSkill": "%s",\n' "${next_skill:-}"
  printf '  "nextStep": "%s",\n' "${next_step:-}"
  printf '  "goalNow": "%s",\n' "${goal_now:-}"
  printf '  "latestCheckpoint": "%s",\n' "${checkpoint:-}"
  printf '  "updated": "%s"\n' "${updated:-}"
  printf '}\n'
  exit 0
fi

echo "hiq_root=$ROOT"
echo "session=$([[ -f "$SESSION" ]] && echo ok || echo missing)"
echo "current_change=$([[ -f "$CURRENT" ]] && echo ok || echo missing)"
echo "entry_skill=${entry_skill_json:-${entry_skill:-unknown}}"
echo "entry_mode=${entry_mode_json:-${entry_mode:-unknown}}"
echo "auto_status=${auto_status_json:-${auto_status:-unknown}}"
echo "auto_owner=${auto_owner_json:-${auto_owner:-unknown}}"
echo "auto_reason=${auto_reason_json:-${auto_reason:-}}"
echo "manual_override=${manual_override_json:-${manual_override:-none}}"
echo "active_change=${active_change:-none}"
echo "phase=${phase:-unknown}"
echo "owner_skill=${owner_skill:-unknown}"
echo "next_skill=${next_skill:-unknown}"
echo "goal_now=${goal_now:-}"
echo "checkpoint=${checkpoint:-none}"
echo "updated=${updated:-unknown}"
if [[ -n "$current_phase" && -n "$phase" && "$current_phase" != "$phase" ]]; then
  echo "warning=session_phase_mismatch session=$phase current_change=$current_phase"
fi
