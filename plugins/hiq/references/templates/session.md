# Session

> Updated by `$hiq-session`. This file is the compact-safe local resume packet.

## Pointer

- **started**:
- **updated**:
- **agent**:
- **state_revision**: 1
- **change_id**: none
- **state_status**: idle | active | blocked | handoff | accepted
- **content_revision**: 0
- **entry_skill**: `hiq-auto` | `hiq` | manual
- **entry_mode**: auto | manual | override | continue | handoff
- **host_target**: unknown | liveagent | codex | claude | project
- **host_automation_level**: unavailable | instruction-only | turn-scoped | persistent
- **host_automation_evidence**: `AGENTS.md` or a verifiable host artifact
- **auto_status**: available | active | manual | disabled | blocked | accepted | handoff
- **auto_owner**: `hiq-...` or none
- **auto_reason**:
- **manual_override**: none | `hiq-...`
- **active_change**: `.hiq/changes/<id>/` or none
- **phase**: idle | init | install | grill | implement | debug | review | evolve | knowledge | skill
- **next_skill**:
- **next_step**:

## Runtime State

- **config**: `.hiq/config.yaml`
- **current_change_record**: `.hiq/current-change.json`
- **status_command**: `bash "$HOME/.hiq/scripts/hiq-status.sh" .`
- **doctor_command**: `bash "$HOME/.hiq/scripts/hiq-doctor.sh" .`
- **status_command_windows**: `%USERPROFILE%\.hiq\scripts\hiq-status.cmd .`
- **doctor_command_windows**: `%USERPROFILE%\.hiq\scripts\hiq-doctor.cmd .`

## Work Now

- **goal_record**: `.hiq/goals/<id>.md` or none
- **goal_now**:
- **blockers**:
- **acceptance_target**:
- **review_status**: not-run | pending | pass | partial | fail | blocked
- **review_path**: `.hiq/changes/<id>/review.md` or none
- **reviewed_content_revision**: none | number
- **eval_applicability**: unknown | not-applicable | optional | required
- **eval_status**: not-run | running | pass | fail | blocked | not-applicable
- **eval_run_path**: `.hiq/eval/runs/<file>` or none
- **eval_reason**:
- **verify_commands**:
- **verify_commands_source**: `.hiq/session.md`
- **verify_cwd**: `.`
- **verify_status**: unset | valid | stale | unrunnable | waived
- **verify_waiver_reason**:

## Code / Graph

- **codegraph_state**: ok | stale | missing
- **codegraph_anchors**: symbols / modules / files that matter now
- **last_green**: latest known passing local checks

## Resume Safety

- **checkpoint_required**: no | yes
- **checkpoint_reason**: none | handoff | compaction | context-pressure
- **resume_source**: fresh | session | checkpoint | manual
- **latest_checkpoint**: `context-checkpoints/<file>.md` or none
- **compact_safe_summary**: 5-10 lines that a brand new session can trust

## History

- **last_action**:
- **next_action**:
