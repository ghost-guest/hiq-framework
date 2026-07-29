#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SMOKE_ROOT="${1:-$REPO_ROOT/tmp/hiq-smoke-project}"
KEEP="${2:-}"
SMOKE_HOME="$REPO_ROOT/tmp/hiq-smoke-home"

DISPATCHER_ROOT="$REPO_ROOT/tmp/hiq-dispatcher-smoke-project"
mkdir -p "$DISPATCHER_ROOT"

cleanup() {
  if [[ "$KEEP" != "--keep" ]]; then
    rm -rf "$SMOKE_ROOT" "$SMOKE_HOME" "$DISPATCHER_ROOT"
  fi
}
trap cleanup EXIT

fail() {
  echo "hiq-smoke: FAIL - $*" >&2
  exit 1
}

rm -rf "$SMOKE_ROOT" "$SMOKE_HOME"
mkdir -p "$SMOKE_ROOT" "$SMOKE_HOME/scripts" "$SMOKE_HOME/bin"
cp "$SCRIPT_DIR/hiq-run.sh" "$SCRIPT_DIR/hiq-status.sh" "$SCRIPT_DIR/hiq-doctor.sh" "$SMOKE_HOME/scripts/"
chmod +x "$SMOKE_HOME/scripts"/*.sh
export HIQ_HOME_DIR="$SMOKE_HOME"
export HIQ_BIN_DIR="$SMOKE_HOME/bin"

echo "hiq-smoke: init-project root=$SMOKE_ROOT"
bash "$SCRIPT_DIR/init-project.sh" "$SMOKE_ROOT" >/dev/null

grep -q 'schema: 2' "$SMOKE_ROOT/.hiq/config.yaml" || fail 'config did not use schema 2'
grep -q 'host_automation_level.*instruction-only' "$SMOKE_ROOT/.hiq/session.md" || fail 'missing honest host automation level'
grep -q '"hostAutomationLevel": "instruction-only"' "$SMOKE_ROOT/.hiq/current-change.json" || fail 'missing hostAutomationLevel in current-change.json'
grep -q '"autoStatus": "available"' "$SMOKE_ROOT/.hiq/current-change.json" || fail 'fresh init must report autoStatus=available'
grep -q '"entrySkill": "hiq-auto"' "$SMOKE_ROOT/.hiq/current-change.json" || fail 'missing entrySkill in current-change.json'
grep -q '"autoOwnerSkill": "hiq-session"' "$SMOKE_ROOT/.hiq/current-change.json" || fail 'missing autoOwnerSkill in current-change.json'
grep -q '"reviewStatus": "not-run"' "$SMOKE_ROOT/.hiq/current-change.json" || fail 'missing reviewStatus in current-change.json'
grep -q '"evalApplicability": "not-applicable"' "$SMOKE_ROOT/.hiq/current-change.json" || fail 'missing eval applicability truth'
grep -q '"checkpointRequired": false' "$SMOKE_ROOT/.hiq/current-change.json" || fail 'missing checkpointRequired in current-change.json'
grep -q -- '- \*\*entry_skill\*\*: `hiq-auto`' "$SMOKE_ROOT/.hiq/session.md" || fail 'missing entry_skill in session.md'
grep -q -- '- \*\*auto_owner\*\*: `hiq-session`' "$SMOKE_ROOT/.hiq/session.md" || fail 'missing auto_owner in session.md'
grep -q -- '- \*\*goal_record\*\*:' "$SMOKE_ROOT/.hiq/session.md" || fail 'missing goal_record in session.md'

grep -q 'accepted complete result' "$REPO_ROOT/plugins/hiq/references/templates/goal.md" || fail 'goal template missing accepted complete result field'
grep -q 'scope downgrade approved' "$REPO_ROOT/plugins/hiq/references/templates/grill.md" || fail 'grill template missing scope downgrade approval field'
grep -q 'plan updated?' "$REPO_ROOT/plugins/hiq/references/templates/grill.md" || fail 'grill template missing post-decision plan update field'
grep -q 'scope_downgrade_approved' "$REPO_ROOT/plugins/hiq/references/templates/IMPLEMENT.md" || fail 'IMPLEMENT template missing scope downgrade approval metadata'
grep -q 'grill.md` (required before L1+ product work)' "$REPO_ROOT/plugins/hiq/references/templates/IMPLEMENT.md" || fail 'IMPLEMENT template missing grill-before-implement rule'

status_out="$(bash "$SCRIPT_DIR/hiq-status.sh" "$SMOKE_ROOT")"
doctor_pre="$(bash "$SCRIPT_DIR/hiq-doctor.sh" "$SMOKE_ROOT")"

echo "$status_out" | grep -q 'session=ok' || fail 'status did not report session=ok after init-project'
echo "$status_out" | grep -q 'entry_skill=hiq-auto' || fail 'status should report entry_skill=hiq-auto after init-project'
echo "$status_out" | grep -q 'host_automation_level=instruction-only' || fail 'status should report instruction-only host automation'
echo "$status_out" | grep -q 'auto_status=available' || fail 'status should report autoStatus=available before a real turn enters'
echo "$status_out" | grep -q 'auto_owner=hiq-session' || fail 'status should report auto_owner=hiq-session after init-project'
echo "$status_out" | grep -q 'pointer_status=ok' || fail 'status should report an aligned fresh pointer'
echo "$doctor_pre" | grep -q 'runtime.codegraph_index=missing' || fail 'doctor should report missing codegraph index before project-init'
echo "$doctor_pre" | grep -q 'state.overall=ok' || fail 'doctor should report semantic state healthy after init-project'
echo "$doctor_pre" | grep -q 'overall=partial' || fail 'doctor should report overall=partial before project-init'

echo "hiq-smoke: project-init root=$SMOKE_ROOT"
bash "$SCRIPT_DIR/codegraph-project-init.sh" "$SMOKE_ROOT" >/dev/null

doctor_post="$(bash "$SCRIPT_DIR/hiq-doctor.sh" "$SMOKE_ROOT")"
echo "$doctor_post" | grep -q 'runtime.codegraph_index=ok' || fail 'doctor should report codegraph index ok after project-init'
echo "$doctor_post" | grep -q 'state.overall=ok' || fail 'doctor should report semantic state healthy after project-init'
echo "$doctor_post" | grep -q 'overall=ok' || fail 'doctor should report overall=ok after project-init'

python3 - <<PY
import json
from pathlib import Path
path = Path('$SMOKE_ROOT/.hiq/current-change.json')
data = json.loads(path.read_text())
path.write_text(json.dumps(data, separators=(',', ':')))
PY
compact_status="$(bash "$SCRIPT_DIR/hiq-status.sh" "$SMOKE_ROOT")"
echo "$compact_status" | grep -q 'entry_skill=hiq-auto' || fail 'status could not read compact current-change.json'
echo "$compact_status" | grep -q 'host_automation_level=instruction-only' || fail 'status could not read compact hostAutomationLevel'
python3 - <<PY
import json
from pathlib import Path
path = Path('$SMOKE_ROOT/.hiq/current-change.json')
data = json.loads(path.read_text())
path.write_text(json.dumps(data, indent=2) + '\n')
PY

# Semantic regression fixtures: strict mode must reject drift that existence checks miss.
CURRENT_FILE="$SMOKE_ROOT/.hiq/current-change.json"
SESSION_FILE="$SMOKE_ROOT/.hiq/session.md"
cp "$CURRENT_FILE" "$CURRENT_FILE.bak"
cp "$SESSION_FILE" "$SESSION_FILE.bak"
sed -i.bak 's/"ownerSkill": "hiq-session"/"ownerSkill": "hiq-implement"/' "$CURRENT_FILE"
if bash "$SCRIPT_DIR/hiq-doctor.sh" "$SMOKE_ROOT" --strict >/dev/null 2>&1; then fail 'strict doctor accepted owner/phase drift'; fi
mv "$CURRENT_FILE.bak" "$CURRENT_FILE"

sed -i.bak 's/"hostAutomationEvidence": "AGENTS.md"/"hostAutomationEvidence": "missing-agents.md"/' "$CURRENT_FILE"
sed -i.bak 's/- \*\*host_automation_evidence\*\*: `AGENTS.md`/- **host_automation_evidence**: missing-agents.md/' "$SESSION_FILE"
if bash "$SCRIPT_DIR/hiq-doctor.sh" "$SMOKE_ROOT" --strict >/dev/null 2>&1; then fail 'strict doctor accepted missing host automation evidence'; fi
mv "$CURRENT_FILE.bak" "$CURRENT_FILE"
mv "$SESSION_FILE.bak" "$SESSION_FILE"
cp "$SESSION_FILE" "$SESSION_FILE.bak"

sed -i.bak 's/"stateStatus": "idle"/"stateStatus": "accepted"/; s/"autoStatus": "available"/"autoStatus": "accepted"/; s/"reviewStatus": "not-run"/"reviewStatus": "pass"/' "$CURRENT_FILE"
if bash "$SCRIPT_DIR/hiq-doctor.sh" "$SMOKE_ROOT" --strict >/dev/null 2>&1; then fail 'strict doctor accepted missing review proof'; fi
mv "$CURRENT_FILE.bak" "$CURRENT_FILE"

sed -i.bak 's/"verifyStatus": "unset"/"verifyStatus": "valid"/' "$CURRENT_FILE"
sed -i.bak 's/- \*\*verify_status\*\*: unset/- **verify_status**: valid/; s/- \*\*verify_commands\*\*:$/- **verify_commands**: `python3 --object config\/objects\/deleted.json`/' "$SESSION_FILE"
if bash "$SCRIPT_DIR/hiq-doctor.sh" "$SMOKE_ROOT" --strict >/dev/null 2>&1; then fail 'strict doctor accepted stale verify path'; fi
mv "$CURRENT_FILE.bak" "$CURRENT_FILE"
mv "$SESSION_FILE.bak" "$SESSION_FILE"

grep -q '"command": ".hiq/tools/codegraph"' "$SMOKE_ROOT/.mcp.json" || fail 'repo mcp should use project-relative codegraph launcher'
grep -q '"hiq_command_windows": ".hiq/tools/codegraph.cmd"' "$SMOKE_ROOT/.hiq/graph/mcp-liveagent.json" || fail 'liveagent snippet should document Windows launcher'

preview_out="$(bash "$SCRIPT_DIR/install-skills.sh" liveagent '' 0)"
echo "$preview_out" | grep -q 'skill=hiq-auto' || fail 'install preview missing hiq-auto'
echo "$preview_out" | grep -q 'mode=preview' || fail 'install preview did not stay in preview mode'

DISPATCHER_ROOT="$REPO_ROOT/tmp/hiq-dispatcher-smoke-project"
rm -rf "$DISPATCHER_ROOT"
mkdir -p "$DISPATCHER_ROOT"
bash "$SCRIPT_DIR/hiq-run.sh" init-project "$DISPATCHER_ROOT" >/dev/null
test -d "$DISPATCHER_ROOT/.hiq" || fail 'dispatcher init-project did not create .hiq at requested root'

if [[ -e "$REPO_ROOT/init-project" ]]; then
  fail 'dispatcher created stray init-project path'
fi

echo 'smoke:'
echo '- macOS/Linux init-project: passed'
echo '- macOS/Linux project-init: passed'
echo '- install preview surface: passed'
if [[ "$KEEP" == "--keep" ]]; then
  echo "- kept project: $SMOKE_ROOT"
fi
