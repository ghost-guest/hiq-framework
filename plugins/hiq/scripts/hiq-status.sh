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

active_change="$(md_field active_change "$SESSION")"
phase="$(md_field phase "$SESSION")"
next_skill="$(md_field next_skill "$SESSION")"
next_step="$(md_field next_step "$SESSION")"
goal_now="$(md_field goal_now "$SESSION")"
checkpoint="$(md_field latest_checkpoint "$SESSION")"
updated="$(md_field updated "$SESSION")"
owner_skill="$(json_field ownerSkill "$CURRENT")"
current_phase="$(json_field phase "$CURRENT")"

if [[ "$JSON_MODE" == "--json" ]]; then
  printf '{\n'
  printf '  "root": "%s",\n' "$ROOT"
  printf '  "hiq": "%s",\n' "$HIQ"
  printf '  "sessionExists": %s,\n' "$( [[ -f "$SESSION" ]] && echo true || echo false )"
  printf '  "currentChangeExists": %s,\n' "$( [[ -f "$CURRENT" ]] && echo true || echo false )"
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
