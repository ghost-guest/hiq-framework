#!/usr/bin/env bash
set -euo pipefail

ROOT="."
if [[ $# -gt 0 && "${1:-}" != --* ]]; then
  ROOT="$1"
  shift
fi
ROOT="$(cd "$ROOT" && pwd)"

MODE="auto"
GOAL_TITLE=""
GOAL_NOW=""
ACCEPTANCE=""
OWNER="hiq-session"
PHASE=""
NEXT_SKILL=""
NEXT_STEP=""
REASON="hiq-auto activated for this project turn"
MANUAL_OVERRIDE="none"
STATE_STATUS="active"
AUTO_STATUS="active"
ACTIVE_CHANGE="none"
RESUME_SOURCE="session"
HOST_TARGET=""
HOST_LEVEL=""
HOST_EVIDENCE=""
HOOK_ADAPTER=""
IF_NEEDED=false
JSON_MODE=false

for arg in "$@"; do
  case "$arg" in
    --mode=*) MODE="${arg#--mode=}" ;;
    --goal-title=*) GOAL_TITLE="${arg#--goal-title=}" ;;
    --goal-now=*) GOAL_NOW="${arg#--goal-now=}" ;;
    --acceptance=*) ACCEPTANCE="${arg#--acceptance=}" ;;
    --owner=*) OWNER="${arg#--owner=}" ;;
    --phase=*) PHASE="${arg#--phase=}" ;;
    --next-skill=*) NEXT_SKILL="${arg#--next-skill=}" ;;
    --next-step=*) NEXT_STEP="${arg#--next-step=}" ;;
    --reason=*) REASON="${arg#--reason=}" ;;
    --manual-override=*) MANUAL_OVERRIDE="${arg#--manual-override=}" ;;
    --state-status=*) STATE_STATUS="${arg#--state-status=}" ;;
    --auto-status=*) AUTO_STATUS="${arg#--auto-status=}" ;;
    --active-change=*) ACTIVE_CHANGE="${arg#--active-change=}" ;;
    --resume-source=*) RESUME_SOURCE="${arg#--resume-source=}" ;;
    --host=*) HOST_TARGET="${arg#--host=}" ;;
    --host-level=*) HOST_LEVEL="${arg#--host-level=}" ;;
    --host-evidence=*) HOST_EVIDENCE="${arg#--host-evidence=}" ;;
    --hook-adapter=*) HOOK_ADAPTER="${arg#--hook-adapter=}" ;;
    --if-needed) IF_NEEDED=true ;;
    --json) JSON_MODE=true ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

case "$OWNER" in
  hiq-session) DEFAULT_PHASE=idle ;;
  hiq-init) DEFAULT_PHASE=init ;;
  hiq-install) DEFAULT_PHASE=install ;;
  hiq-grill) DEFAULT_PHASE=grill ;;
  hiq-implement) DEFAULT_PHASE=implement ;;
  hiq-debug) DEFAULT_PHASE=debug ;;
  hiq-review) DEFAULT_PHASE=review ;;
  hiq-evolve) DEFAULT_PHASE=evolve ;;
  hiq-knowledge) DEFAULT_PHASE=knowledge ;;
  hiq-skill) DEFAULT_PHASE=skill ;;
  hiq) DEFAULT_PHASE=idle ;;
  *) DEFAULT_PHASE=idle ;;
esac
[[ -n "$PHASE" ]] || PHASE="$DEFAULT_PHASE"
[[ -n "$NEXT_SKILL" ]] || NEXT_SKILL="$OWNER"
if [[ -z "$NEXT_STEP" ]]; then
  case "$OWNER" in
    hiq-grill) NEXT_STEP="clarify scope, confirm acceptance target, and choose the truthful next owner lane" ;;
    hiq-session) NEXT_STEP="rebuild pointer and resume the truthful current owner step" ;;
    hiq-debug) NEXT_STEP="freeze the symptom, identify root cause, and define the next repair step" ;;
    hiq-review) NEXT_STEP="refresh proof for the current revision and decide acceptance honestly" ;;
    *) NEXT_STEP="execute the truthful next owner step for this goal" ;;
  esac
fi

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python)"
fi
if [[ -z "$PYTHON_BIN" ]]; then
  echo "hiq-activate: python3/python is required" >&2
  exit 1
fi

HIQ="$ROOT/.hiq"
CURRENT="$HIQ/current-change.json"
SESSION="$HIQ/session.md"
GOALS_DIR="$HIQ/goals"
mkdir -p "$GOALS_DIR"

"$PYTHON_BIN" - "$ROOT" "$CURRENT" "$SESSION" "$GOALS_DIR" "$MODE" "$GOAL_TITLE" "$GOAL_NOW" "$ACCEPTANCE" "$OWNER" "$PHASE" "$NEXT_SKILL" "$NEXT_STEP" "$REASON" "$MANUAL_OVERRIDE" "$STATE_STATUS" "$AUTO_STATUS" "$ACTIVE_CHANGE" "$RESUME_SOURCE" "$HOST_TARGET" "$HOST_LEVEL" "$HOST_EVIDENCE" "$HOOK_ADAPTER" "$IF_NEEDED" "$JSON_MODE" <<'PY'
import json
import re
import sys
from datetime import datetime
from pathlib import Path

(
    root,
    current_path_s,
    session_path_s,
    goals_dir_s,
    mode,
    goal_title,
    goal_now,
    acceptance,
    owner,
    phase,
    next_skill,
    next_step,
    reason,
    manual_override,
    state_status,
    auto_status,
    active_change,
    resume_source,
    host_target,
    host_level,
    host_evidence,
    hook_adapter,
    if_needed,
    json_mode,
) = sys.argv[1:25]

current_path = Path(current_path_s)
session_path = Path(session_path_s)
goals_dir = Path(goals_dir_s)
stamp = datetime.now().astimezone().strftime("%Y-%m-%dT%H:%M:%S%z")
stamp_id = datetime.now().strftime("%Y%m%d-%H%M%S")

def load_json(path: Path) -> dict:
    if not path.exists():
        return {"framework": "hiq", "schema": 2}
    return json.loads(path.read_text(encoding="utf-8"))

def as_int(value, default=0):
    try:
        return int(value)
    except Exception:
        return default

def normalize_none(value):
    if value is None:
        return "none"
    value = str(value).strip()
    return value if value and value not in {"null", "None"} else "none"

def slugify(text: str) -> str:
    ascii_text = re.sub(r"[^A-Za-z0-9]+", "-", text).strip("-").lower()
    return ascii_text[:48] if ascii_text else "goal"

def replace_md_field(text: str, key: str, value: str) -> str:
    pattern = re.compile(rf"^- \*\*{re.escape(key)}\*\*:.*$", re.MULTILINE)
    line = f"- **{key}**: {value}"
    if pattern.search(text):
        return pattern.sub(line, text)
    return text

def format_goal_value(value: str, code=False) -> str:
    normalized = normalize_none(value)
    if normalized == "none":
        return "none"
    return f"`{value}`" if code else value

current = load_json(current_path)
if if_needed == "true" and current.get("autoStatus") == "active" and current.get("goalPath"):
    result = {
        "goalId": current.get("goalId"),
        "goalPath": current.get("goalPath"),
        "ownerSkill": current.get("ownerSkill"),
        "phase": current.get("phase"),
        "autoStatus": current.get("autoStatus"),
        "stateRevision": current.get("stateRevision"),
        "updatedAt": current.get("updatedAt"),
        "skipped": True,
    }
    if json_mode == "true":
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print("skipped=true")
        for key in ("goalId", "goalPath", "ownerSkill", "phase", "autoStatus", "stateRevision"):
            print(f"{key}={result.get(key)}")
    raise SystemExit(0)
state_revision = as_int(current.get("stateRevision"), 0) + 1
content_revision = as_int(current.get("contentRevision"), 0)
review_status = current.get("reviewStatus") or "not-run"
review_path = normalize_none(current.get("reviewPath"))
reviewed_revision = normalize_none(current.get("reviewedContentRevision"))
resolved_goal_now = goal_now.strip() or str(current.get("goalNow") or "").strip() or goal_title.strip() or "Resume truthful HiQ coordination"
resolved_acceptance = acceptance.strip() or str(current.get("acceptanceTarget") or "").strip() or resolved_goal_now
resolved_goal_title = goal_title.strip() or resolved_goal_now
existing_goal_id = normalize_none(current.get("goalId"))
existing_goal_path = normalize_none(current.get("goalPath"))

if existing_goal_id != "none" and existing_goal_path != "none" and (Path(root) / existing_goal_path).exists():
    goal_id = existing_goal_id
    goal_path = existing_goal_path
else:
    goal_id = f"goal-{stamp_id}-{slugify(resolved_goal_title)}"
    goal_path = f".hiq/goals/{goal_id}.md"

goal_file = Path(root) / goal_path

if not host_target:
    host_target = str(current.get("hostTarget") or "unknown")
if not host_level:
    host_level = str(current.get("hostAutomationLevel") or "instruction-only")
if not hook_adapter:
    hook_adapter = str(current.get("hookAdapter") or "none")
if not host_evidence:
    host_evidence = str(current.get("hostAutomationEvidence") or "AGENTS.md")
if normalize_none(active_change) == "none":
    active_change = normalize_none(current.get("activeChange"))

current.update({
    "framework": "hiq",
    "schema": 2,
    "stateRevision": state_revision,
    "entrySkill": "hiq-auto",
    "entryMode": mode,
    "hostTarget": host_target,
    "hostAutomationLevel": host_level,
    "hostAutomationEvidence": None if normalize_none(host_evidence) == "none" else host_evidence,
    "hookAdapter": hook_adapter,
    "autoStatus": auto_status,
    "autoOwnerSkill": owner,
    "autoReason": reason,
    "manualOverride": manual_override,
    "activeChange": None if normalize_none(active_change) == "none" else active_change,
    "stateStatus": state_status,
    "phase": phase,
    "ownerSkill": owner,
    "nextSkill": next_skill,
    "nextStep": next_step,
    "goalId": goal_id,
    "goalPath": goal_path,
    "goalNow": resolved_goal_now,
    "acceptanceTarget": resolved_acceptance,
    "resumeSource": resume_source,
    "updatedAt": stamp,
})
current_path.write_text(json.dumps(current, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

if session_path.exists():
    text = session_path.read_text(encoding="utf-8")
    replacements = {
        "updated": stamp,
        "state_revision": str(state_revision),
        "entry_skill": "`hiq-auto`",
        "entry_mode": mode,
        "auto_status": auto_status,
        "auto_owner": f"`{owner}`",
        "auto_reason": reason,
        "manual_override": manual_override,
        "active_change": format_goal_value(active_change, code=True),
        "state_status": state_status,
        "phase": phase,
        "next_skill": next_skill,
        "next_step": next_step,
        "goal_record": f"`{goal_path}`",
        "goal_now": resolved_goal_now,
        "acceptance_target": resolved_acceptance,
        "review_status": review_status,
        "review_path": format_goal_value(review_path, code=True),
        "reviewed_content_revision": reviewed_revision,
        "resume_source": resume_source,
    }
    for key, value in replacements.items():
        text = replace_md_field(text, key, value)
    text = replace_md_field(text, "last_action", f"hiq-auto activation -> owner {owner}")
    text = replace_md_field(text, "next_action", next_step)
    session_path.write_text(text, encoding="utf-8")

owner_table_row = f"| {state_revision} | `{owner}` | {mode} | activate | {reason} | active | {next_skill} |"
if goal_file.exists():
    goal_text = goal_file.read_text(encoding="utf-8")
    goal_text = replace_md_field(goal_text, "state_revision", str(state_revision))
    goal_text = replace_md_field(goal_text, "content_revision", str(content_revision))
    goal_text = replace_md_field(goal_text, "status", state_status)
    goal_text = replace_md_field(goal_text, "mode", mode)
    goal_text = replace_md_field(goal_text, "current_owner", f"`{owner}`")
    goal_text = replace_md_field(goal_text, "next_owner", f"`{next_skill}`")
    goal_text = replace_md_field(goal_text, "active_change", format_goal_value(active_change, code=True))
    goal_text = replace_md_field(goal_text, "review_status", review_status)
    goal_text = replace_md_field(goal_text, "review_path", format_goal_value(review_path, code=True))
    goal_text = replace_md_field(goal_text, "reviewed_content_revision", reviewed_revision)
    goal_text = replace_md_field(goal_text, "updated", stamp)
    goal_text = re.sub(r"(?m)^- user request:.*$", f"- user request: {resolved_goal_title}", goal_text)
    goal_text = re.sub(r"(?m)^- accepted complete result:.*$", f"- accepted complete result: {resolved_acceptance}", goal_text)
    goal_text = re.sub(r"(?m)^- goal_now:.*$", f"- goal_now: {resolved_goal_now}", goal_text)
    goal_text = re.sub(r"(?m)^- acceptance target:.*$", f"- acceptance target: {resolved_acceptance}", goal_text)
    goal_text = re.sub(r"(?m)^- why this owner is current:.*$", f"- why this owner is current: {reason}", goal_text)
    goal_text = re.sub(r"(?m)^- owner lease action:.*$", f"- owner lease action: {next_step}", goal_text)
    goal_text = re.sub(r"(?m)^- owner lease started:.*$", f"- owner lease started: {stamp}", goal_text)
    goal_text = re.sub(r"(?m)^- evidence gap:.*$", "- evidence gap: current owner output is still needed", goal_text)
    goal_text = re.sub(r"(?m)^- acceptance item still open:.*$", f"- acceptance item still open: {resolved_acceptance}", goal_text)
    if owner_table_row not in goal_text and "## 5. Acceptance ledger" in goal_text:
        goal_text = goal_text.replace("## 5. Acceptance ledger", owner_table_row + "\n\n## 5. Acceptance ledger", 1)
else:
    goal_text = f"""# Goal — {resolved_goal_title}

- **goal_id**: `{goal_id}`
- **state_revision**: {state_revision}
- **content_revision**: {content_revision}
- **entry_skill**: `hiq-auto`
- **status**: {state_status}
- **mode**: {mode}
- **current_owner**: `{owner}`
- **next_owner**: `{next_skill}`
- **active_change**: {format_goal_value(active_change, code=True)}
- **review_status**: {review_status}
- **review_path**: {format_goal_value(review_path, code=True)}
- **reviewed_content_revision**: {reviewed_revision}
- **updated**: {stamp}

## 1. Requested outcome

- user request: {resolved_goal_title}
- accepted complete result: {resolved_acceptance}
- staged delivery approved?: no
- scope downgrade approved?: no

## 2. Goal statement

- goal_now: {resolved_goal_now}
- non-goals:
- acceptance target: {resolved_acceptance}
- anti-downgrade rule: MVP / prototype / first-version / placeholder requires explicit user approval

## 3. Current truthful bottleneck

- why this owner is current: {reason}
- owner lease action: {next_step}
- owner lease started: {stamp}
- evidence gap: current owner output is still needed
- explicit blocker if any:
- user-owned inputs still pending:
- acceptance item still open: {resolved_acceptance}

## 4. Owner transition ledger

| step | owner | mode | trigger | reason | result | next |
|------|-------|------|---------|--------|--------|------|
{owner_table_row}

## 5. Acceptance ledger

| item | required proof | current status | source |
|------|----------------|----------------|--------|
| A1 | {resolved_acceptance} | open | |

## 6. Evidence ledger

| time | content revision | owner | evidence | freshness | impact |
|------|------------------|-------|----------|-----------|--------|
| {stamp} | {content_revision} | `{owner}` | hiq-auto activation state | fresh | goal pointer established |

## 7. User decisions

| id | question | why user-owned | status | answer |
|----|----------|----------------|--------|--------|
| D1 | | | open | |

## 8. Handoff / checkpoint

- checkpoint_required: no
- checkpoint_reason: none
- latest_checkpoint:
- resume command: `$hiq-auto`

## 9. Final verdict

- accepted?: no
- review verdict: PENDING
- review source:
- reviewed content revision: {content_revision}
- follow-up work:
"""

goal_file.parent.mkdir(parents=True, exist_ok=True)
goal_file.write_text(goal_text if goal_text.endswith("\n") else goal_text + "\n", encoding="utf-8")

result = {
    "goalId": goal_id,
    "goalPath": goal_path,
    "ownerSkill": owner,
    "phase": phase,
    "autoStatus": auto_status,
    "stateRevision": state_revision,
    "updatedAt": stamp,
}
if json_mode == "true":
    print(json.dumps(result, indent=2, ensure_ascii=False))
else:
    for key in ("goalId", "goalPath", "ownerSkill", "phase", "autoStatus", "stateRevision"):
        print(f"{key}={result[key]}")
PY
