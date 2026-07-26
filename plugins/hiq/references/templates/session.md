# Session

> Updated by `$hiq-session`. This file is the compact-safe local resume packet.

## Pointer

- **started**:
- **updated**:
- **agent**:
- **active_change**: `.hiq/changes/<id>/` or none
- **phase**: idle | grill | implement | debug | review | evolve | knowledge | skill
- **next_skill**:
- **next_step**:

## Runtime State

- **config**: `.hiq/config.yaml`
- **current_change_record**: `.hiq/current-change.json`
- **status_command**: `bash "$HOME/.hiq/scripts/hiq-status.sh" .`
- **doctor_command**: `bash "$HOME/.hiq/scripts/hiq-doctor.sh" .`

## Work Now

- **goal_record**: `.hiq/goals/<id>.md` or none
- **goal_now**:
- **blockers**:
- **acceptance_target**:
- **verify_commands**:

## Code / Graph

- **codegraph_state**: ok | stale | missing
- **codegraph_anchors**: symbols / modules / files that matter now
- **last_green**: latest known passing local checks

## Resume Safety

- **latest_checkpoint**: `context-checkpoints/<file>.md` or none
- **compact_safe_summary**: 5-10 lines that a brand new session can trust

## History

- **last_action**:
- **next_action**:
