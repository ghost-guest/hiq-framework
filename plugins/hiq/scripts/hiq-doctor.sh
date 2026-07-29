#!/usr/bin/env bash
set -euo pipefail

ROOT="."
if [[ $# -gt 0 && "${1:-}" != --* ]]; then
  ROOT="$1"
  shift
fi
ROOT="$(cd "$ROOT" && pwd)"
JSON_MODE=false
STRICT_MODE=false
for arg in "$@"; do
  case "$arg" in
    --json) JSON_MODE=true ;;
    --strict) STRICT_MODE=true ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

HIQ="$ROOT/.hiq"
HIQ_HOME="${HIQ_HOME_DIR:-$HOME/.hiq}"
SESSION="$HIQ/session.md"
CURRENT="$HIQ/current-change.json"
CONFIG="$HIQ/config.yaml"
MANIFEST="$HIQ/runtime-manifest.json"
BOOTSTRAP="$HIQ/BOOTSTRAP.md"
MEMORY="$HIQ/MEMORY.md"

check_file() {
  [[ -f "$1" ]] && echo ok || echo missing
}

check_dir() {
  [[ -d "$1" ]] && echo ok || echo missing
}

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
try:
    data = json.load(open(sys.argv[2], encoding='utf-8'))
except Exception:
    raise SystemExit(1)
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
  sed -n "s/^[[:space:]]*\"$key\"[[:space:]]*:[[:space:]]*//p" "$file" \
    | head -n1 \
    | sed 's/[[:space:]]*,[[:space:]]*$//'
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

json_parse_ok() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  if [[ -n "$PYTHON_BIN" ]]; then
    "$PYTHON_BIN" - "$file" <<'PY'
import json, sys
with open(sys.argv[1], encoding='utf-8') as handle:
    json.load(handle)
PY
    return $?
  fi
  return 1
}

yaml_field() {
  local key="$1"
  local file="$2"
  [[ -f "$file" ]] || return 0
  sed -n "s/^[[:space:]]*$key:[[:space:]]*//p" "$file" | head -n1 | sed "s/^['\"]//; s/['\"]$//"
}

normalize_none() {
  case "${1:-}" in
    ""|none|null) printf '%s' none ;;
    *) printf '%s' "$1" ;;
  esac
}

is_none() {
  [[ "$(normalize_none "${1:-}")" == none ]]
}

is_safe_relative_path() {
  local value="$1"
  [[ -n "$value" ]] || return 1
  case "$value" in
    /*|[A-Za-z]:*|*'..'*) return 1 ;;
  esac
  return 0
}

resolve_project_path() {
  local value="$1"
  value="${value#./}"
  printf '%s/%s' "$ROOT" "$value"
}

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g'
}

project_ok=true
runtime_ok=true
state_ok=true
state_json=ok
state_schema=ok
state_reconciliation=ok
state_owner=ok
state_review=ok
state_eval=ok
state_checkpoint=ok
state_verify=ok
state_hook=ok
issue_count=0
issues=""

record_issue() {
  local category="$1"
  local code="$2"
  local detail="$3"
  state_ok=false
  issue_count=$((issue_count + 1))
  issues="${issues}${code}|${detail}"$'\n'
  case "$category" in
    json) state_json=partial ;;
    schema) state_schema=partial ;;
    reconciliation) state_reconciliation=partial ;;
    owner) state_owner=partial ;;
    review) state_review=partial ;;
    eval) state_eval=partial ;;
    checkpoint) state_checkpoint=partial ;;
    verify) state_verify=partial ;;
    hook) state_hook=partial ;;
  esac
}

compare_state() {
  local category="$1"
  local code="$2"
  local left="$3"
  local right="$4"
  if [[ "$(normalize_none "$left")" != "$(normalize_none "$right")" ]]; then
    record_issue "$category" "$code" "current=$(normalize_none "$left") session=$(normalize_none "$right")"
  fi
}

for file in "$BOOTSTRAP" "$MEMORY" "$SESSION" "$CONFIG" "$CURRENT" "$MANIFEST"; do
  if [[ ! -f "$file" ]]; then
    project_ok=false
  fi
done

active_change_session="$(md_field active_change "$SESSION")"
change_dir_status=none
if ! is_none "$active_change_session"; then
  if is_safe_relative_path "$active_change_session" && [[ -d "$(resolve_project_path "$active_change_session")" ]]; then
    change_dir_status=ok
  else
    change_dir_status=missing
    project_ok=false
  fi
fi

codegraph_bin="$HIQ_HOME/bin/codegraph"
codegraph_status="$([[ -x "$codegraph_bin" ]] && echo ok || echo missing)"
codegraph_index="$(check_dir "$ROOT/.codegraph")"
global_scripts_status="$(check_file "$HIQ_HOME/scripts/hiq-run.sh")"
global_status_status="$(check_file "$HIQ_HOME/scripts/hiq-status.sh")"
global_doctor_status="$(check_file "$HIQ_HOME/scripts/hiq-doctor.sh")"
global_hook_status="$(check_file "$HIQ_HOME/scripts/hiq-hook.sh")"
for status in "$global_scripts_status" "$global_status_status" "$global_doctor_status" "$global_hook_status" "$codegraph_status" "$codegraph_index"; do
  if [[ "$status" != ok ]]; then
    runtime_ok=false
  fi
done

if [[ ! -f "$CURRENT" ]]; then
  record_issue json state.current_missing ".hiq/current-change.json is missing"
else
  if ! json_parse_ok "$CURRENT"; then
    if [[ -n "$PYTHON_BIN" ]]; then
      record_issue json state.json_invalid "current-change.json cannot be parsed as JSON"
    else
      record_issue json state.json_parser_unavailable "POSIX doctor needs python3/python for strict JSON validation"
    fi
  fi
  first_nonblank="$(sed -n '/[^[:space:]]/{p;q;}' "$CURRENT")"
  last_nonblank="$(sed -n '/[^[:space:]]/h;${x;p;}' "$CURRENT")"
  if [[ "$first_nonblank" != \{ || "$last_nonblank" != \} ]]; then
    record_issue json state.json_invalid "current-change.json must be a flat JSON object"
  fi
fi

schema="$(json_field schema "$CURRENT")"
framework="$(json_field framework "$CURRENT")"
required_keys=(
  stateRevision changeId stateStatus contentRevision entrySkill entryMode hostTarget
  hostAutomationLevel hostAutomationEvidence hookProtocolVersion hookCoreStatus hookAdapter
  hookLastEvent hookLastRunPath hookLastRunAt hookLastRunStatus autoStatus autoOwnerSkill autoReason manualOverride
  activeChange phase ownerSkill nextSkill nextStep goalId goalPath goalNow acceptanceTarget
  reviewStatus reviewPath reviewedContentRevision acceptedAt evalApplicability evalStatus
  evalRunPath evalReason checkpointRequired checkpointReason resumeSource latestCheckpoint
  verifyCommandsSource verifyCwd verifyStatus verifyWaiverReason updatedAt
)
if [[ "$framework" != hiq ]]; then
  record_issue schema state.framework_invalid "framework must be hiq"
fi
if [[ "$schema" != 2 ]]; then
  record_issue schema state.schema_legacy "schema=$schema; run hiq-init refresh to add schema 2 fields"
fi
for key in "${required_keys[@]}"; do
  if [[ -z "$(json_raw "$key" "$CURRENT")" ]]; then
    record_issue schema "state.field_missing.$key" "$key is missing"
  fi
done

state_revision="$(json_field stateRevision "$CURRENT")"
change_id="$(json_field changeId "$CURRENT")"
state_status="$(json_field stateStatus "$CURRENT")"
content_revision="$(json_field contentRevision "$CURRENT")"
entry_skill="$(json_field entrySkill "$CURRENT")"
entry_mode="$(json_field entryMode "$CURRENT")"
host_target="$(json_field hostTarget "$CURRENT")"
host_level="$(json_field hostAutomationLevel "$CURRENT")"
host_evidence="$(json_field hostAutomationEvidence "$CURRENT")"
hook_protocol="$(json_field hookProtocolVersion "$CURRENT")"
hook_core="$(json_field hookCoreStatus "$CURRENT")"
hook_adapter="$(json_field hookAdapter "$CURRENT")"
hook_last_event="$(json_field hookLastEvent "$CURRENT")"
hook_last_run="$(json_field hookLastRunPath "$CURRENT")"
hook_last_run_at="$(json_field hookLastRunAt "$CURRENT")"
hook_last_status="$(json_field hookLastRunStatus "$CURRENT")"
auto_status="$(json_field autoStatus "$CURRENT")"
auto_owner="$(json_field autoOwnerSkill "$CURRENT")"
manual_override="$(json_field manualOverride "$CURRENT")"
active_change="$(json_field activeChange "$CURRENT")"
phase="$(json_field phase "$CURRENT")"
owner_skill="$(json_field ownerSkill "$CURRENT")"
next_skill="$(json_field nextSkill "$CURRENT")"
next_step="$(json_field nextStep "$CURRENT")"
goal_id="$(json_field goalId "$CURRENT")"
goal_path="$(json_field goalPath "$CURRENT")"
goal_now="$(json_field goalNow "$CURRENT")"
acceptance_target="$(json_field acceptanceTarget "$CURRENT")"
review_status="$(json_field reviewStatus "$CURRENT")"
review_path="$(json_field reviewPath "$CURRENT")"
reviewed_revision="$(json_field reviewedContentRevision "$CURRENT")"
accepted_at="$(json_field acceptedAt "$CURRENT")"
eval_applicability="$(json_field evalApplicability "$CURRENT")"
eval_status="$(json_field evalStatus "$CURRENT")"
eval_run_path="$(json_field evalRunPath "$CURRENT")"
eval_reason="$(json_field evalReason "$CURRENT")"
checkpoint_required="$(json_field checkpointRequired "$CURRENT")"
checkpoint_reason="$(json_field checkpointReason "$CURRENT")"
resume_source="$(json_field resumeSource "$CURRENT")"
latest_checkpoint="$(json_field latestCheckpoint "$CURRENT")"
verify_source="$(json_field verifyCommandsSource "$CURRENT")"
verify_cwd="$(json_field verifyCwd "$CURRENT")"
verify_status="$(json_field verifyStatus "$CURRENT")"
verify_waiver="$(json_field verifyWaiverReason "$CURRENT")"

case "$state_status" in idle|active|blocked|handoff|accepted) ;; *) record_issue schema state.status_invalid "stateStatus=$state_status" ;; esac
case "$host_level" in unavailable|instruction-only|adapter-available|turn-scoped|persistent) ;; *) record_issue schema state.host_level_invalid "hostAutomationLevel=$host_level" ;; esac
case "$hook_core" in missing|available|running|failed) ;; *) record_issue hook state.hook_core_invalid "hookCoreStatus=$hook_core" ;; esac
case "$hook_last_event" in ""|none|null|pre-session|pre-tool|post-tool|pre-final|checkpoint|status) ;; *) record_issue hook state.hook_event_invalid "hookLastEvent=$hook_last_event" ;; esac
case "$hook_last_status" in none|pass|fail) ;; *) record_issue hook state.hook_status_invalid "hookLastRunStatus=$hook_last_status" ;; esac
case "$auto_status" in available|active|manual|disabled|blocked|accepted|handoff) ;; *) record_issue schema state.auto_status_invalid "autoStatus=$auto_status" ;; esac
case "$review_status" in not-run|pending|pass|partial|fail|blocked) ;; *) record_issue schema state.review_status_invalid "reviewStatus=$review_status" ;; esac
case "$eval_applicability" in unknown|not-applicable|optional|required) ;; *) record_issue schema state.eval_applicability_invalid "evalApplicability=$eval_applicability" ;; esac
case "$eval_status" in not-run|running|pass|fail|blocked|not-applicable) ;; *) record_issue schema state.eval_status_invalid "evalStatus=$eval_status" ;; esac
case "$checkpoint_reason" in none|handoff|compaction|context-pressure) ;; *) record_issue schema state.checkpoint_reason_invalid "checkpointReason=$checkpoint_reason" ;; esac
case "$resume_source" in fresh|session|checkpoint|manual) ;; *) record_issue schema state.resume_source_invalid "resumeSource=$resume_source" ;; esac
case "$verify_status" in unset|valid|stale|unrunnable|waived) ;; *) record_issue schema state.verify_status_invalid "verifyStatus=$verify_status" ;; esac

compare_state reconciliation state.revision_mismatch "$state_revision" "$(md_field state_revision "$SESSION")"
compare_state reconciliation state.change_id_mismatch "$change_id" "$(md_field change_id "$SESSION")"
compare_state reconciliation state.status_mismatch "$state_status" "$(md_field state_status "$SESSION")"
compare_state reconciliation state.content_revision_mismatch "$content_revision" "$(md_field content_revision "$SESSION")"
compare_state reconciliation state.entry_skill_mismatch "$entry_skill" "$(md_field entry_skill "$SESSION")"
compare_state reconciliation state.entry_mode_mismatch "$entry_mode" "$(md_field entry_mode "$SESSION")"
compare_state reconciliation state.host_target_mismatch "$host_target" "$(md_field host_target "$SESSION")"
compare_state reconciliation state.host_level_mismatch "$host_level" "$(md_field host_automation_level "$SESSION")"
compare_state reconciliation state.host_evidence_mismatch "$host_evidence" "$(md_field host_automation_evidence "$SESSION")"
compare_state reconciliation state.hook_protocol_mismatch "$hook_protocol" "$(md_field hook_protocol_version "$SESSION")"
compare_state reconciliation state.hook_core_mismatch "$hook_core" "$(md_field hook_core_status "$SESSION")"
compare_state reconciliation state.hook_adapter_mismatch "$hook_adapter" "$(md_field hook_adapter "$SESSION")"
compare_state reconciliation state.hook_event_mismatch "$hook_last_event" "$(md_field hook_last_event "$SESSION")"
compare_state reconciliation state.hook_run_mismatch "$hook_last_run" "$(md_field hook_last_run "$SESSION")"
compare_state reconciliation state.hook_status_mismatch "$hook_last_status" "$(md_field hook_last_status "$SESSION")"
compare_state reconciliation state.auto_status_mismatch "$auto_status" "$(md_field auto_status "$SESSION")"
compare_state reconciliation state.auto_owner_mismatch "$auto_owner" "$(md_field auto_owner "$SESSION")"
compare_state reconciliation state.manual_override_mismatch "$manual_override" "$(md_field manual_override "$SESSION")"
compare_state reconciliation state.active_change_mismatch "$active_change" "$active_change_session"
compare_state reconciliation state.phase_mismatch "$phase" "$(md_field phase "$SESSION")"
compare_state reconciliation state.next_skill_mismatch "$next_skill" "$(md_field next_skill "$SESSION")"
compare_state reconciliation state.next_step_mismatch "$next_step" "$(md_field next_step "$SESSION")"
compare_state reconciliation state.goal_path_mismatch "$goal_path" "$(md_field goal_record "$SESSION")"
compare_state reconciliation state.goal_now_mismatch "$goal_now" "$(md_field goal_now "$SESSION")"
compare_state reconciliation state.acceptance_target_mismatch "$acceptance_target" "$(md_field acceptance_target "$SESSION")"
compare_state reconciliation state.review_status_mismatch "$review_status" "$(md_field review_status "$SESSION")"
compare_state reconciliation state.review_path_mismatch "$review_path" "$(md_field review_path "$SESSION")"
compare_state reconciliation state.review_revision_mismatch "$reviewed_revision" "$(md_field reviewed_content_revision "$SESSION")"
compare_state reconciliation state.eval_applicability_mismatch "$eval_applicability" "$(md_field eval_applicability "$SESSION")"
compare_state reconciliation state.eval_status_mismatch "$eval_status" "$(md_field eval_status "$SESSION")"
compare_state reconciliation state.eval_run_mismatch "$eval_run_path" "$(md_field eval_run_path "$SESSION")"
session_checkpoint_required="$(md_field checkpoint_required "$SESSION")"
case "$session_checkpoint_required" in
  yes) session_checkpoint_required=true ;;
  no) session_checkpoint_required=false ;;
esac
compare_state reconciliation state.checkpoint_required_mismatch "$checkpoint_required" "$session_checkpoint_required"
compare_state reconciliation state.checkpoint_reason_mismatch "$checkpoint_reason" "$(md_field checkpoint_reason "$SESSION")"
compare_state reconciliation state.resume_source_mismatch "$resume_source" "$(md_field resume_source "$SESSION")"
compare_state reconciliation state.checkpoint_mismatch "$latest_checkpoint" "$(md_field latest_checkpoint "$SESSION")"
compare_state reconciliation state.verify_source_mismatch "$verify_source" "$(md_field verify_commands_source "$SESSION")"
compare_state reconciliation state.verify_cwd_mismatch "$verify_cwd" "$(md_field verify_cwd "$SESSION")"
compare_state reconciliation state.verify_status_mismatch "$verify_status" "$(md_field verify_status "$SESSION")"

if ! is_none "$active_change"; then
  if ! is_safe_relative_path "$active_change" || [[ ! -d "$(resolve_project_path "$active_change")" ]]; then
    record_issue reconciliation state.active_change_missing "activeChange=$active_change"
  fi
  active_id="$(basename "${active_change%/}")"
  if ! is_none "$change_id" && [[ "$change_id" != "$active_id" ]]; then
    record_issue reconciliation state.change_id_path_mismatch "changeId=$change_id activeChange=$active_change"
  fi
elif ! is_none "$change_id"; then
  record_issue reconciliation state.change_without_path "changeId=$change_id but activeChange is empty"
fi

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
  *) expected_owner=""; record_issue owner state.phase_invalid "phase=$phase" ;;
esac
if [[ -n "$expected_owner" && "$owner_skill" != "$expected_owner" ]]; then
  record_issue owner state.owner_phase_mismatch "phase=$phase ownerSkill=$owner_skill expected=$expected_owner"
fi
if is_none "$manual_override"; then
  if [[ "$auto_owner" != "$owner_skill" ]]; then
    record_issue owner state.auto_owner_lease_mismatch "autoOwnerSkill=$auto_owner ownerSkill=$owner_skill"
  fi
elif [[ "$owner_skill" != "$manual_override" ]]; then
  record_issue owner state.manual_override_owner_mismatch "manualOverride=$manual_override ownerSkill=$owner_skill"
fi

if [[ "$host_level" == turn-scoped || "$host_level" == persistent ]]; then
  if is_none "$host_evidence" || ! is_safe_relative_path "$host_evidence" || [[ ! -f "$(resolve_project_path "$host_evidence")" ]]; then
    record_issue owner state.host_evidence_missing "hostAutomationEvidence=$host_evidence"
  fi
elif ! is_none "$host_evidence"; then
  if ! is_safe_relative_path "$host_evidence" || [[ ! -f "$(resolve_project_path "$host_evidence")" ]]; then
    record_issue owner state.host_evidence_missing "hostAutomationEvidence=$host_evidence"
  elif ! grep -q '^# HiQ Project Rule' "$(resolve_project_path "$host_evidence")" 2>/dev/null || ! grep -q 'hiq-auto' "$(resolve_project_path "$host_evidence")" 2>/dev/null; then
    record_issue owner state.host_evidence_not_hiq "hostAutomationEvidence=$host_evidence does not contain the HiQ auto contract"
  fi
fi

if [[ "$hook_protocol" != 1 ]]; then
  record_issue hook state.hook_protocol_invalid "hookProtocolVersion=$hook_protocol"
fi
if [[ "$hook_core" == available && "$global_hook_status" != ok ]]; then
  record_issue hook state.hook_core_missing "hookCoreStatus=available but hiq-hook.sh is missing from runtime scripts"
fi
if [[ "$host_level" == turn-scoped || "$host_level" == persistent ]]; then
  if is_none "$hook_last_run" || ! is_safe_relative_path "$hook_last_run" || [[ "$hook_last_run" != .hiq/hooks/runs/* ]] || [[ ! -f "$(resolve_project_path "$hook_last_run")" ]]; then
    record_issue hook state.hook_run_missing "hookLastRunPath=$hook_last_run"
  fi
  if [[ "$hook_last_status" != pass ]]; then
    record_issue hook state.hook_run_not_pass "hookLastRunStatus=$hook_last_status"
  fi
  if [[ "$host_evidence" != "$hook_last_run" ]]; then
    record_issue hook state.hook_evidence_mismatch "hostAutomationEvidence=$host_evidence hookLastRunPath=$hook_last_run"
  fi
elif [[ "$host_level" == instruction-only ]]; then
  if ! is_none "$hook_last_run"; then
    record_issue hook state.hook_run_without_level "hookLastRunPath=$hook_last_run requires hostAutomationLevel turn-scoped or persistent"
  fi
fi

review_file=""
if ! is_none "$review_path"; then
  if is_safe_relative_path "$review_path" && [[ -f "$(resolve_project_path "$review_path")" ]]; then
    review_file="$(resolve_project_path "$review_path")"
  else
    record_issue review state.review_path_missing "reviewPath=$review_path"
  fi
fi
if [[ "$owner_skill" == hiq-review || "$phase" == review ]]; then
  if [[ -z "$review_file" || "$review_status" == not-run ]]; then
    record_issue review state.review_owner_without_artifact "hiq-review ownership requires a current review artifact"
  fi
fi
if [[ "$state_status" == accepted || "$auto_status" == accepted ]]; then
  if [[ "$review_status" != pass ]]; then
    record_issue review state.accepted_without_review_pass "reviewStatus=$review_status"
  fi
  if is_none "$accepted_at"; then
    record_issue review state.accepted_without_timestamp "accepted state requires acceptedAt"
  fi
  if is_none "$change_id" || is_none "$active_change"; then
    record_issue review state.accepted_without_change "accepted state requires changeId and activeChange"
  fi
  if [[ -z "$review_file" ]]; then
    record_issue review state.accepted_without_review_path "accepted state requires reviewPath"
  else
    review_verdict="$(md_field verdict "$review_file")"
    review_revision="$(md_field reviewed_content_revision "$review_file")"
    review_change_id="$(md_field change_id "$review_file")"
    if [[ "$review_verdict" != PASS ]]; then
      record_issue review state.review_verdict_not_pass "review verdict=$review_verdict"
    fi
    if [[ "$review_revision" != "$content_revision" || "$reviewed_revision" != "$content_revision" ]]; then
      record_issue review state.review_revision_stale "contentRevision=$content_revision stateReviewed=$reviewed_revision artifactReviewed=$review_revision"
    fi
    if ! is_none "$change_id" && [[ "$review_change_id" != "$change_id" ]]; then
      record_issue review state.review_change_mismatch "changeId=$change_id artifactChangeId=$review_change_id"
    fi
    review_path_normalized="${review_path#./}"
    active_change_normalized="${active_change#./}"
    expected_review_path="${active_change_normalized%/}/review.md"
    if ! is_none "$active_change" && [[ "$review_path_normalized" != "$expected_review_path" ]]; then
      record_issue review state.review_path_not_canonical "reviewPath=$review_path expected=$expected_review_path"
    fi
  fi
fi

eval_file=""
if ! is_none "$eval_run_path" && is_safe_relative_path "$eval_run_path" && [[ -f "$(resolve_project_path "$eval_run_path")" ]]; then
  eval_file="$(resolve_project_path "$eval_run_path")"
fi
if [[ -n "$eval_file" ]]; then
  eval_run_normalized="${eval_run_path#./}"
  if [[ "$eval_run_normalized" != .hiq/eval/runs/* ]]; then
    record_issue eval state.eval_run_outside_root "evalRunPath=$eval_run_path"
  fi
  eval_report_status="$(md_field status "$eval_file")"
  eval_report_change="$(md_field change "$eval_file")"
  eval_report_change_id="$(md_field change_id "$eval_file")"
  eval_report_revision="$(md_field content_revision "$eval_file")"
  if [[ "$eval_status" == pass && "$eval_report_status" != done ]]; then
    record_issue eval state.eval_report_not_done "eval report status=$eval_report_status"
  fi
  if ! is_none "$change_id" && [[ "$eval_report_change_id" != "$change_id" ]]; then
    record_issue eval state.eval_change_mismatch "changeId=$change_id evalChangeId=$eval_report_change_id"
  fi
  if ! is_none "$active_change" && [[ "$(normalize_none "$eval_report_change")" != "$(normalize_none "$active_change")" ]]; then
    record_issue eval state.eval_change_path_mismatch "activeChange=$active_change evalChange=$eval_report_change"
  fi
  if [[ "$eval_status" == pass && "$eval_report_revision" != "$content_revision" ]]; then
    record_issue eval state.eval_revision_stale "contentRevision=$content_revision evalRevision=$eval_report_revision"
  fi
fi
case "$eval_applicability" in
  unknown)
    record_issue eval state.eval_applicability_unknown "classify eval as not-applicable, optional, or required"
    ;;
  not-applicable)
    if [[ "$eval_status" != not-applicable || -z "$eval_reason" || "$eval_reason" == null ]]; then
      record_issue eval state.eval_not_applicable_incomplete "not-applicable eval requires matching status and reason"
    fi
    ;;
  optional)
    if [[ "$eval_status" == pass || "$eval_status" == fail ]]; then
      if [[ -z "$eval_file" ]]; then
        record_issue eval state.eval_run_missing "evalStatus=$eval_status evalRunPath=$eval_run_path"
      fi
    fi
    ;;
  required)
    if [[ "$eval_status" != pass ]]; then
      record_issue eval state.eval_required_not_passed "evalStatus=$eval_status"
    fi
    if [[ -z "$eval_file" ]]; then
      record_issue eval state.eval_required_run_missing "evalRunPath=$eval_run_path"
    fi
    ;;
esac

checkpoint_needed=false
if [[ "$checkpoint_required" == true || "$state_status" == handoff || "$auto_status" == handoff || "$entry_mode" == handoff || "$checkpoint_reason" != none ]]; then
  checkpoint_needed=true
fi
if $checkpoint_needed && is_none "$latest_checkpoint"; then
  record_issue checkpoint state.checkpoint_required_missing "checkpointReason=$checkpoint_reason"
fi
if ! is_none "$latest_checkpoint"; then
  if ! is_safe_relative_path "$latest_checkpoint" || [[ "$latest_checkpoint" != context-checkpoints/* ]] || [[ ! -f "$(resolve_project_path "$latest_checkpoint")" ]]; then
    record_issue checkpoint state.checkpoint_path_invalid "latestCheckpoint=$latest_checkpoint"
  fi
fi
if [[ "$resume_source" == checkpoint ]] && is_none "$latest_checkpoint"; then
  record_issue checkpoint state.resume_checkpoint_missing "resumeSource=checkpoint requires latestCheckpoint"
fi

verify_commands="$(md_field verify_commands "$SESSION")"
verify_base="$ROOT"
if ! is_none "$verify_cwd"; then
  if ! is_safe_relative_path "$verify_cwd" || [[ ! -d "$(resolve_project_path "$verify_cwd")" ]]; then
    record_issue verify state.verify_cwd_missing "verifyCwd=$verify_cwd"
  else
    verify_base="$(resolve_project_path "$verify_cwd")"
  fi
fi
if ! is_none "$verify_source"; then
  if ! is_safe_relative_path "$verify_source" || [[ ! -f "$(resolve_project_path "$verify_source")" ]]; then
    record_issue verify state.verify_source_missing "verifyCommandsSource=$verify_source"
  fi
fi
case "$verify_status" in
  unset|waived)
    if [[ -z "$verify_waiver" || "$verify_waiver" == null ]]; then
      record_issue verify state.verify_waiver_missing "verifyStatus=$verify_status requires verifyWaiverReason"
    fi
    ;;
  valid)
    if [[ -z "$verify_commands" ]]; then
      record_issue verify state.verify_commands_missing "verifyStatus=valid but verify_commands is empty"
    fi
    ;;
  stale|unrunnable)
    record_issue verify state.verify_not_runnable "verifyStatus=$verify_status"
    ;;
esac

if [[ -n "$verify_commands" ]]; then
  while IFS= read -r token; do
    token="${token#\`}"
    token="${token%\`}"
    token="${token#\"}"
    token="${token%\"}"
    token="${token#\'}"
    token="${token%\'}"
    token="${token%,}"
    token="${token%;}"
    token="${token%)}"
    token="${token#(}"
    [[ -n "$token" ]] || continue
    case "$token" in
      -*|http://*|https://*|*'$'*|*'%'*|*'<'*|*'>'*) continue ;;
    esac
    case "$token" in
      */*|*\\*|*.json|*.yaml|*.yml|*.toml|*.md|*.py|*.js|*.ts|*.sh|*.ps1|*.cmd|*.exe)
        candidate="$token"
        candidate="${candidate#./}"
        case "$candidate" in
          /*|[A-Za-z]:*) continue ;;
        esac
        if [[ ! -e "$verify_base/$candidate" && ! -e "$ROOT/$candidate" ]]; then
          record_issue verify state.verify_path_missing "verify command references $token"
        fi
        ;;
    esac
  done < <(printf '%s\n' "$verify_commands" | tr ' ' '\n')
fi

if ! is_none "$goal_path" || ! is_none "$goal_id"; then
  goal_file=""
  if ! is_none "$goal_path" && is_safe_relative_path "$goal_path" && [[ -f "$(resolve_project_path "$goal_path")" ]]; then
    goal_file="$(resolve_project_path "$goal_path")"
  else
    record_issue reconciliation state.goal_path_missing "goalPath=$goal_path"
  fi
  if [[ -n "$goal_file" ]]; then
    compare_state reconciliation state.goal_id_file_mismatch "$goal_id" "$(md_field goal_id "$goal_file")"
    compare_state reconciliation state.goal_revision_mismatch "$state_revision" "$(md_field state_revision "$goal_file")"
    compare_state reconciliation state.goal_content_revision_mismatch "$content_revision" "$(md_field content_revision "$goal_file")"
    compare_state reconciliation state.goal_owner_mismatch "$owner_skill" "$(md_field current_owner "$goal_file")"
    compare_state reconciliation state.goal_next_owner_mismatch "$next_skill" "$(md_field next_owner "$goal_file")"
    compare_state reconciliation state.goal_active_change_mismatch "$active_change" "$(md_field active_change "$goal_file")"
    compare_state reconciliation state.goal_review_status_mismatch "$review_status" "$(md_field review_status "$goal_file")"
    compare_state reconciliation state.goal_review_path_mismatch "$review_path" "$(md_field review_path "$goal_file")"
    compare_state reconciliation state.goal_review_revision_mismatch "$reviewed_revision" "$(md_field reviewed_content_revision "$goal_file")"
    compare_state reconciliation state.goal_checkpoint_mismatch "$latest_checkpoint" "$(md_field latest_checkpoint "$goal_file")"
  fi
elif [[ "$entry_skill" == hiq-auto && "$auto_status" =~ ^(active|accepted|handoff)$ ]]; then
  record_issue reconciliation state.goal_required_missing "autoStatus=$auto_status requires goalPath and goalId"
fi

config_schema="$(yaml_field schema "$CONFIG")"
config_eval_enabled="$(yaml_field eval_enabled "$CONFIG")"
config_review_required="$(yaml_field require_review_acceptance "$CONFIG")"
if [[ "$config_schema" != 2 ]]; then
  record_issue schema state.config_schema_legacy "config schema=$config_schema"
fi
if [[ "$config_eval_enabled" == true && -z "$eval_applicability" ]]; then
  record_issue eval state.eval_truth_missing "eval capability is enabled but applicability is absent"
fi
if [[ "$config_review_required" == true && "$state_status" == accepted && "$review_status" != pass ]]; then
  record_issue review state.review_policy_unsatisfied "require_review_acceptance=true"
fi

state_overall="$($state_ok && echo ok || echo partial)"
overall="$($project_ok && $runtime_ok && $state_ok && echo ok || echo partial)"

if $JSON_MODE; then
  printf '{\n'
  printf '  "root": "%s",\n' "$(json_escape "$ROOT")"
  printf '  "project": {"bootstrap":"%s","memory":"%s","session":"%s","config":"%s","currentChange":"%s","manifest":"%s","evalRoot":"%s","activeChangeDir":"%s"},\n' \
    "$(check_file "$BOOTSTRAP")" "$(check_file "$MEMORY")" "$(check_file "$SESSION")" "$(check_file "$CONFIG")" "$(check_file "$CURRENT")" "$(check_file "$MANIFEST")" "$(check_dir "$HIQ/eval")" "$change_dir_status"
  printf '  "runtime": {"hiqHome":"%s","codegraphBin":"%s","codegraphIndex":"%s","hiqRun":"%s","hiqStatus":"%s","hiqDoctor":"%s","hiqHook":"%s"},\n' \
    "$(json_escape "$HIQ_HOME")" "$codegraph_status" "$codegraph_index" "$global_scripts_status" "$global_status_status" "$global_doctor_status" "$global_hook_status"
  printf '  "state": {"json":"%s","schema":"%s","reconciliation":"%s","owner":"%s","review":"%s","eval":"%s","checkpoint":"%s","verify":"%s","hook":"%s","issueCount":%s,"issues":[' \
    "$state_json" "$state_schema" "$state_reconciliation" "$state_owner" "$state_review" "$state_eval" "$state_checkpoint" "$state_verify" "$state_hook" "$issue_count"
  first=true
  while IFS='|' read -r code detail; do
    [[ -n "$code" ]] || continue
    if $first; then first=false; else printf ','; fi
    printf '{"code":"%s","detail":"%s"}' "$(json_escape "$code")" "$(json_escape "$detail")"
  done <<< "$issues"
  printf ']},\n'
  printf '  "stateOverall": "%s",\n' "$state_overall"
  printf '  "overall": "%s"\n' "$overall"
  printf '}\n'
else
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
  echo "runtime.hiq_hook=$global_hook_status"
  echo "state.json=$state_json"
  echo "state.schema=$state_schema"
  echo "state.reconciliation=$state_reconciliation"
  echo "state.owner=$state_owner"
  echo "state.review=$state_review"
  echo "state.eval=$state_eval"
  echo "state.checkpoint=$state_checkpoint"
  echo "state.verify=$state_verify"
  echo "state.hook=$state_hook"
  echo "state.issue_count=$issue_count"
  while IFS='|' read -r code detail; do
    [[ -n "$code" ]] || continue
    echo "issue.$code=$detail"
  done <<< "$issues"
  echo "state.overall=$state_overall"
  echo "overall=$overall"
fi

if $STRICT_MODE && [[ "$overall" != ok ]]; then
  exit 1
fi
