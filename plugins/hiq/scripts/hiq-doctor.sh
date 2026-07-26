#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"
HIQ="$ROOT/.hiq"
HIQ_HOME="${HIQ_HOME_DIR:-$HOME/.hiq}"
SESSION="$HIQ/session.md"
CURRENT="$HIQ/current-change.json"
CONFIG="$HIQ/config.yaml"
MANIFEST="$HIQ/runtime-manifest.json"
BOOTSTRAP="$HIQ/BOOTSTRAP.md"
MEMORY="$HIQ/MEMORY.md"
JSON_MODE="${2:-}"

check_file() {
  local path="$1"
  [[ -f "$path" ]] && echo ok || echo missing
}

check_dir() {
  local path="$1"
  [[ -d "$path" ]] && echo ok || echo missing
}

md_field() {
  local key="$1"
  local file="$2"
  if [[ ! -f "$file" ]]; then
    return 0
  fi
  sed -n "s/^- \*\*$key\*\*: //p" "$file" | head -n1 | sed 's/^`//; s/`$//'
}

active_change="$(md_field active_change "$SESSION")"
codegraph_bin="$HIQ_HOME/bin/codegraph"
codegraph_status="$( [[ -x "$codegraph_bin" ]] && echo ok || echo missing )"
codegraph_index="$(check_dir "$ROOT/.codegraph")"
project_ok=true
runtime_ok=true

for f in "$BOOTSTRAP" "$MEMORY" "$SESSION" "$CONFIG" "$CURRENT" "$MANIFEST"; do
  if [[ ! -f "$f" ]]; then
    project_ok=false
  fi
done

change_dir_status=none
if [[ -n "$active_change" && "$active_change" != "none" ]]; then
  if [[ -d "$ROOT/${active_change#./}" || -d "$active_change" ]]; then
    change_dir_status=ok
  else
    change_dir_status=missing
    project_ok=false
  fi
fi

global_scripts_status="$(check_file "$HIQ_HOME/scripts/hiq-run.sh")"
global_status_status="$(check_file "$HIQ_HOME/scripts/hiq-status.sh")"
global_doctor_status="$(check_file "$HIQ_HOME/scripts/hiq-doctor.sh")"

for s in "$global_scripts_status" "$global_status_status" "$global_doctor_status" "$codegraph_status" "$codegraph_index"; do
  if [[ "$s" != "ok" ]]; then
    runtime_ok=false
  fi
done

if [[ "$JSON_MODE" == "--json" ]]; then
  printf '{\n'
  printf '  "root": "%s",\n' "$ROOT"
  printf '  "project": {\n'
  printf '    "bootstrap": "%s",\n' "$(check_file "$BOOTSTRAP")"
  printf '    "memory": "%s",\n' "$(check_file "$MEMORY")"
  printf '    "session": "%s",\n' "$(check_file "$SESSION")"
  printf '    "config": "%s",\n' "$(check_file "$CONFIG")"
  printf '    "currentChange": "%s",\n' "$(check_file "$CURRENT")"
  printf '    "manifest": "%s",\n' "$(check_file "$MANIFEST")"
  printf '    "evalRoot": "%s",\n' "$(check_dir "$HIQ/eval")"
  printf '    "activeChangeDir": "%s"\n' "$change_dir_status"
  printf '  },\n'
  printf '  "runtime": {\n'
  printf '    "hiqHome": "%s",\n' "$HIQ_HOME"
  printf '    "codegraphBin": "%s",\n' "$codegraph_status"
  printf '    "codegraphIndex": "%s",\n' "$codegraph_index"
  printf '    "hiqRun": "%s",\n' "$global_scripts_status"
  printf '    "hiqStatus": "%s",\n' "$global_status_status"
  printf '    "hiqDoctor": "%s"\n' "$global_doctor_status"
  printf '  },\n'
  printf '  "overall": "%s"\n' "$( [[ "$project_ok" == true && "$runtime_ok" == true ]] && echo ok || echo partial )"
  printf '}\n'
  exit 0
fi

echo "hiq_root=$ROOT"
echo "project.bootstrap=$(check_file "$BOOTSTRAP")"
echo "project.memory=$(check_file "$MEMORY")"
echo "project.session=$(check_file "$SESSION")"
echo "project.config=$(check_file "$CONFIG")"
echo "project.current_change=$(check_file "$CURRENT")"
echo "project.manifest=$(check_file "$MANIFEST")"
echo "project.eval_root=$(check_dir "$HIQ/eval")"
echo "project.active_change_dir=$change_dir_status"
echo "runtime.hiq_home=$HIQ_HOME"
echo "runtime.codegraph_bin=$codegraph_status"
echo "runtime.codegraph_index=$codegraph_index"
echo "runtime.hiq_run=$global_scripts_status"
echo "runtime.hiq_status=$global_status_status"
echo "runtime.hiq_doctor=$global_doctor_status"
echo "overall=$([[ "$project_ok" == true && "$runtime_ok" == true ]] && echo ok || echo partial)"
