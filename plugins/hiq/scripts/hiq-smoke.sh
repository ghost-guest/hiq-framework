#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SMOKE_ROOT="${1:-$REPO_ROOT/tmp/hiq-smoke-project}"
KEEP="${2:-}"

cleanup() {
  if [[ "$KEEP" != "--keep" ]]; then
    rm -rf "$SMOKE_ROOT"
  fi
}
trap cleanup EXIT

fail() {
  echo "hiq-smoke: FAIL - $*" >&2
  exit 1
}

rm -rf "$SMOKE_ROOT"
mkdir -p "$SMOKE_ROOT"

echo "hiq-smoke: init-project root=$SMOKE_ROOT"
bash "$SCRIPT_DIR/init-project.sh" "$SMOKE_ROOT" >/dev/null

grep -q 'entry_skill: hiq-auto' "$SMOKE_ROOT/.hiq/config.yaml" || fail 'missing hiq-auto entry skill'
grep -q '"entrySkill": "hiq-auto"' "$SMOKE_ROOT/.hiq/current-change.json" || fail 'missing entrySkill in current-change.json'
grep -q '"autoOwnerSkill": "hiq-session"' "$SMOKE_ROOT/.hiq/current-change.json" || fail 'missing autoOwnerSkill in current-change.json'
grep -q '"goalId"' "$SMOKE_ROOT/.hiq/current-change.json" || fail 'missing goalId in current-change.json'
grep -q '"goalPath"' "$SMOKE_ROOT/.hiq/current-change.json" || fail 'missing goalPath in current-change.json'
grep -q -- '- \*\*entry_skill\*\*: `hiq-auto`' "$SMOKE_ROOT/.hiq/session.md" || fail 'missing entry_skill in session.md'
grep -q -- '- \*\*auto_owner\*\*: `hiq-session`' "$SMOKE_ROOT/.hiq/session.md" || fail 'missing auto_owner in session.md'
grep -q -- '- \*\*goal_record\*\*:' "$SMOKE_ROOT/.hiq/session.md" || fail 'missing goal_record in session.md'

status_out="$(bash "$SCRIPT_DIR/hiq-status.sh" "$SMOKE_ROOT")"
doctor_pre="$(bash "$SCRIPT_DIR/hiq-doctor.sh" "$SMOKE_ROOT")"

echo "$status_out" | grep -q 'session=ok' || fail 'status did not report session=ok after init-project'
echo "$status_out" | grep -q 'entry_skill=hiq-auto' || fail 'status should report entry_skill=hiq-auto after init-project'
echo "$status_out" | grep -q 'auto_owner=hiq-session' || fail 'status should report auto_owner=hiq-session after init-project'
echo "$doctor_pre" | grep -q 'runtime.codegraph_index=missing' || fail 'doctor should report missing codegraph index before project-init'
echo "$doctor_pre" | grep -q 'overall=partial' || fail 'doctor should report overall=partial before project-init'

echo "hiq-smoke: project-init root=$SMOKE_ROOT"
bash "$SCRIPT_DIR/codegraph-project-init.sh" "$SMOKE_ROOT" >/dev/null

doctor_post="$(bash "$SCRIPT_DIR/hiq-doctor.sh" "$SMOKE_ROOT")"
echo "$doctor_post" | grep -q 'runtime.codegraph_index=ok' || fail 'doctor should report codegraph index ok after project-init'
echo "$doctor_post" | grep -q 'overall=ok' || fail 'doctor should report overall=ok after project-init'

grep -q '"command": ".hiq/tools/codegraph"' "$SMOKE_ROOT/.mcp.json" || fail 'repo mcp should use project-relative codegraph launcher'
grep -q '"hiq_command_windows": ".hiq/tools/codegraph.cmd"' "$SMOKE_ROOT/.hiq/graph/mcp-liveagent.json" || fail 'liveagent snippet should document Windows launcher'

preview_out="$(bash "$SCRIPT_DIR/install-skills.sh" liveagent '' 0)"
echo "$preview_out" | grep -q 'skill=hiq-auto' || fail 'install preview missing hiq-auto'
echo "$preview_out" | grep -q 'mode=preview' || fail 'install preview did not stay in preview mode'

echo 'smoke:'
echo '- macOS/Linux init-project: passed'
echo '- macOS/Linux project-init: passed'
echo '- install preview surface: passed'
if [[ "$KEEP" == "--keep" ]]; then
  echo "- kept project: $SMOKE_ROOT"
fi
