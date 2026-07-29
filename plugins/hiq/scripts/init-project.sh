#!/usr/bin/env bash
# Mechanical .hiq skeleton for hiq-init (agent-run). Content fill is Agent's job.
set -euo pipefail

ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"
HIQ="$ROOT/.hiq"
STAMP="$(date +%Y-%m-%dT%H:%M:%S%z)"
CURRENT_PREEXISTED=false
SESSION_PREEXISTED=false
[[ -e "$HIQ/current-change.json" ]] && CURRENT_PREEXISTED=true
[[ -e "$HIQ/session.md" ]] && SESSION_PREEXISTED=true

mkdir -p \
  "$HIQ/requirements" \
  "$HIQ/architecture" \
  "$HIQ/adr" \
  "$HIQ/spec" \
  "$HIQ/grill" \
  "$HIQ/tasks" \
  "$HIQ/changes" \
  "$HIQ/archive" \
  "$HIQ/goals" \
  "$HIQ/knowledge" \
  "$HIQ/audits" \
  "$HIQ/graph" \
  "$HIQ/profile" \
  "$HIQ/eval" \
  "$HIQ/eval/runs" \
  "$HIQ/hooks" \
  "$HIQ/hooks/runs" \
  "$HIQ/hooks/adapters"

write_if_absent() {
  local path="$1"
  local content="$2"
  if [[ -e "$path" ]]; then
    echo "exists=$path"
    return 0
  fi
  printf '%s' "$content" >"$path"
  echo "created=$path"
}

write_if_absent "$HIQ/BOOTSTRAP.md" "# Project Bootstrap

> Any new agent/tool: read this file first, then MEMORY.md, config.yaml, and session.md.

## One-liner

(TODO: fill during hiq-init)

## Verify commands

\`\`\`bash
# TODO: test / lint
\`\`\`

## Read order

1. \`.hiq/BOOTSTRAP.md\` (this file)
2. \`.hiq/MEMORY.md\`
3. \`.hiq/config.yaml\`
4. \`.hiq/session.md\`
5. \`.hiq/current-change.json\`
6. \`.hiq/MAP.md\`
7. Active change under \`.hiq/changes/\` if any
8. Code map: \`.hiq/graph/\` + \`codegraph status\`

## Code intelligence

\`\`\`bash
codegraph status
codegraph query <symbol>
codegraph callers <symbol>
codegraph impact <symbol>
codegraph context \"<task>\"
\`\`\`

## Runtime probes

\`\`\`bash
bash \"\$HOME/.hiq/scripts/hiq-status.sh\" .
bash \"\$HOME/.hiq/scripts/hiq-doctor.sh\" .
\`\`\`

## Resume

\`\`\`text
\$hiq-auto
# or: 继续 .hiq/BOOTSTRAP.md
# manual lane override: \$hiq-session / \$hiq-debug / ...
\`\`\`
"

write_if_absent "$HIQ/CONTEXT.md" "# Context

## Product

-

## Users / non-users

-

## Invariants

-

## Glossary

| Term | Meaning |
|------|---------|
|      |         |

## Explicit non-goals

-
"

write_if_absent "$HIQ/MEMORY.md" "# Project Memory

Durable notes for multi-session / multi-agent development. No secrets.

## Product

-

## Architecture notes

-

## Conventions

-

## Active work

- change:
- blocker:
- next:

## Lessons

-

## Agent notes

- env:
- ports:
- verify:
"

write_if_absent "$HIQ/MAP.md" "# Module Map

| Path | Role | Entry | Notes |
|------|------|-------|-------|
|      |      |       |       |

See also: \`graph/modules.md\`, \`graph/edges.md\`, CodeGraph index.
"

write_if_absent "$HIQ/attention.md" "# Attention

Short project conventions that drift easily.

-
"

write_if_absent "$HIQ/config.yaml" "framework: hiq
schema: 2
language: zh-CN
artifacts:
  root: .hiq
  session: .hiq/session.md
  current_change: .hiq/current-change.json
  eval_root: .hiq/eval
state:
  semantic_doctor: true
  require_schema: 2
  require_pointer_reconciliation: true
resume:
  prefer_local_state: true
  require_checkpoint_before_handoff: true
  status_command_posix: bash "\$HOME/.hiq/scripts/hiq-status.sh" .
  status_command_windows: '%USERPROFILE%\\.hiq\\scripts\\hiq-status.cmd .'
review:
  require_fresh_evidence: true
  eval_enabled: true
  eval_enabled_meaning: capability
  eval_config: .hiq/eval/eval.yaml
auto:
  enabled: true
  entry_skill: hiq-auto
  goal_dir: .hiq/goals
  project_rule_file: AGENTS.md
  auto_resume: true
  require_review_acceptance: true
  allow_explicit_skill_override: true
  host_automation_level: instruction-only
  host_automation_evidence: AGENTS.md
verify:
  require_structured_state: true
  check_cwd: true
  check_local_paths: true
hook:
  protocol_version: 1
  core_command_posix: bash "$HOME/.hiq/scripts/hiq-hook.sh"
  core_command_windows: '%USERPROFILE%\.hiq\scripts\hiq-hook.cmd'
  adapter: none
  adapters_dir: .hiq/hooks/adapters
  evidence_root: .hiq/hooks/runs
  require_run_evidence_for_level: turn-scoped
skill:
  retained_count: 11
  stable_surface: true
  compose_enabled: true
  bundle_enabled: true
  publish_enabled: true
install:
  managed_runtime_home: ~/.hiq
  doctor_command_posix: bash "\$HOME/.hiq/scripts/hiq-doctor.sh" .
  doctor_command_windows: '%USERPROFILE%\\.hiq\\scripts\\hiq-doctor.cmd .'
  doctor_strict_posix: bash "\$HOME/.hiq/scripts/hiq-doctor.sh" . --strict
  doctor_strict_windows: '%USERPROFILE%\\.hiq\\scripts\\hiq-doctor.cmd . --strict'
"

write_if_absent "$HIQ/current-change.json" "{
  \"framework\": \"hiq\",
  \"schema\": 2,
  \"stateRevision\": 1,
  \"changeId\": null,
  \"stateStatus\": \"idle\",
  \"contentRevision\": 0,
  \"entrySkill\": \"hiq-auto\",
  \"entryMode\": \"auto\",
  \"hostTarget\": \"unknown\",
  \"hostAutomationLevel\": \"instruction-only\",
  \"hostAutomationEvidence\": \"AGENTS.md\",
  \"hookProtocolVersion\": 1,
  \"hookCoreStatus\": \"available\",
  \"hookAdapter\": \"none\",
  \"hookLastEvent\": null,
  \"hookLastRunPath\": null,
  \"hookLastRunAt\": null,
  \"hookLastRunStatus\": \"none\",
  \"autoStatus\": \"available\",
  \"autoOwnerSkill\": \"hiq-session\",
  \"autoReason\": \"project rule is available; the host must load instructions before hiq-auto can coordinate this turn\",
  \"manualOverride\": \"none\",
  \"activeChange\": null,
  \"phase\": \"idle\",
  \"ownerSkill\": \"hiq-session\",
  \"nextSkill\": \"hiq-session\",
  \"nextStep\": \"rebuild pointer or start the first truthful owner skill\",
  \"goalId\": null,
  \"goalPath\": null,
  \"goalNow\": \"\",
  \"acceptanceTarget\": \"\",
  \"reviewStatus\": \"not-run\",
  \"reviewPath\": null,
  \"reviewedContentRevision\": null,
  \"acceptedAt\": null,
  \"evalApplicability\": \"not-applicable\",
  \"evalStatus\": \"not-applicable\",
  \"evalRunPath\": null,
  \"evalReason\": \"no active change\",
  \"checkpointRequired\": false,
  \"checkpointReason\": \"none\",
  \"resumeSource\": \"fresh\",
  \"latestCheckpoint\": null,
  \"verifyCommandsSource\": \".hiq/session.md\",
  \"verifyCwd\": \".\",
  \"verifyStatus\": \"unset\",
  \"verifyWaiverReason\": \"no verification command recorded\",
  \"updatedAt\": \"$STAMP\"
}
"

write_if_absent "$HIQ/session.md" "# Session

> Updated by \`\$hiq-session\`. This file is the compact-safe local resume packet.

## Pointer

- **started**: $STAMP
- **updated**: $STAMP
- **agent**:
- **state_revision**: 1
- **change_id**: none
- **state_status**: idle
- **content_revision**: 0
- **entry_skill**: \`hiq-auto\`
- **entry_mode**: auto
- **host_target**: unknown
- **host_automation_level**: instruction-only
- **host_automation_evidence**: \`AGENTS.md\`
- **hook_protocol_version**: 1
- **hook_core_status**: available
- **hook_adapter**: none
- **hook_last_event**: none
- **hook_last_run**: none
- **hook_last_status**: none
- **auto_status**: available
- **auto_owner**: \`hiq-session\`
- **auto_reason**: project rule is available; the host must load instructions before hiq-auto can coordinate this turn
- **manual_override**: none
- **active_change**: none
- **phase**: idle
- **next_skill**: hiq-session
- **next_step**: rebuild pointer or start the first truthful owner skill

## Runtime State

- **config**: \`.hiq/config.yaml\`
- **current_change_record**: \`.hiq/current-change.json\`
- **status_command**: \`bash \"\$HOME/.hiq/scripts/hiq-status.sh\" .\`
- **doctor_command**: \`bash \"\$HOME/.hiq/scripts/hiq-doctor.sh\" .\`
- **status_command_windows**: \`%USERPROFILE%\\.hiq\\scripts\\hiq-status.cmd .\`
- **doctor_command_windows**: \`%USERPROFILE%\\.hiq\\scripts\\hiq-doctor.cmd .\`

## Work Now

- **goal_record**: none
- **goal_now**:
- **blockers**:
- **acceptance_target**:
- **review_status**: not-run
- **review_path**: none
- **reviewed_content_revision**: none
- **eval_applicability**: not-applicable
- **eval_status**: not-applicable
- **eval_run_path**: none
- **eval_reason**: no active change
- **verify_commands**:
- **verify_commands_source**: \`.hiq/session.md\`
- **verify_cwd**: \`.\`
- **verify_status**: unset
- **verify_waiver_reason**: no verification command recorded

## Code / Graph

- **codegraph_state**: missing
- **codegraph_anchors**:
- **last_green**:

## Resume Safety

- **checkpoint_required**: no
- **checkpoint_reason**: none
- **resume_source**: fresh
- **latest_checkpoint**: none
- **compact_safe_summary**:

## History

- **last_action**: hiq-init skeleton created
- **next_action**: run hiq-auto or the first truthful owner skill
"

write_if_absent "$HIQ/spec/index.md" "# Spec index

## Verify

\`\`\`bash
# filled by hiq-init from package scripts
\`\`\`

## Layers

- (add package/layer indexes as project grows)

## Quality check pointers

- run lint/type/test before claim done
"

write_if_absent "$HIQ/graph/README.md" "# Code knowledge layer

- **Authoritative symbol graph**: \`.codegraph/\` (CodeGraph)
- **Human/agent navigation**: \`modules.md\`, \`edges.md\`
- During feature/issue work, update \`edges.md\` when you learn new module couplings.
"

write_if_absent "$HIQ/graph/CODEGRAPH.md" "# CodeGraph (Cleboost/codegraph-rs via HiQ)

Engine: https://github.com/Cleboost/codegraph-rs  
Always use HiQ launcher (auto-installs binary):

\`\`\`bash
export PATH=\"\$HOME/.hiq/bin:\$PATH\"
# or:
bash \"\$HOME/.hiq/scripts/codegraph.sh\" <cmd>

codegraph init                 # .codegraph/ + index
codegraph status
codegraph index
codegraph sync
codegraph query <name>
codegraph files
codegraph context \"implement X\"
codegraph serve --mcp
\`\`\`

Repair binary:

\`\`\`bash
bash \"\$HOME/.hiq/scripts/install-codegraph.sh\"
# or from HiQ repo:
bash plugins/hiq/scripts/install-codegraph.sh
\`\`\`

MCP: restart after first init so agents load \`.codegraph/\`.
"

write_if_absent "$HIQ/graph/modules.md" "# Modules

| Module | Path | Responsibility | Key symbols |
|--------|------|----------------|-------------|
|        |      |                |             |
"

write_if_absent "$HIQ/graph/edges.md" "# Module edges

Record \"change A -> check B\" couplings discovered in development.

| From | To | Kind | Why |
|------|----|------|-----|
|      |    |      |     |
"

write_if_absent "$HIQ/eval/README.md" "# Eval

HiQ-native evaluation scaffold absorbed from the useful Comet ideas.

- config: \`.hiq/eval/eval.yaml\`
- reports: \`.hiq/eval/runs/\`
- review owner: \`hiq-review\`
- framework governance owner: \`hiq-skill\`
"

write_if_absent "$HIQ/hooks/README.md" "# HiQ Hooks

Host-neutral hook evidence lives here.

- protocol: .hiq/hooks/hook-state.json + .hiq/hooks/runs/
- adapters: .hiq/hooks/adapters/
- core command: bash \"\$HOME/.hiq/scripts/hiq-hook.sh\" . pre-session --host=generic --adapter=generic
- Windows: %USERPROFILE%\\.hiq\\scripts\\hiq-hook.cmd . pre-session --host=generic --adapter=generic

Do not claim host-level automation from this directory alone. Run evidence under .hiq/hooks/runs/ is required.
"

write_if_absent "$HIQ/hooks/hook-state.json" "{
  \"framework\": \"hiq\",
  \"schema\": 1,
  \"protocolVersion\": 1,
  \"coreStatus\": \"available\",
  \"adapter\": \"none\",
  \"host\": \"unknown\",
  \"automationLevel\": \"instruction-only\",
  \"evidenceRoot\": \".hiq/hooks/runs\",
  \"lastEvent\": null,
  \"lastRunPath\": null,
  \"lastRunAt\": null,
  \"lastRunStatus\": \"none\"
}
"

write_if_absent "$HIQ/eval/eval.yaml" "schema: 2
name: hiq-local-eval
root: .
capability:
  enabled: true
  meaning: available-not-required
  applicability_source: .hiq/current-change.json
artifacts:
  session: .hiq/session.md
  current_change: .hiq/current-change.json
  change_root: .hiq/changes
  evidence_root: .hiq/eval/runs
scope:
  workflow: hiq
  retained_surface: 11
  mode: local
rubric:
  - id: acceptance
    prompt: Does the result satisfy the approved acceptance target with current evidence?
    weight: 0.4
  - id: routing
    prompt: Did the work stay with the truthful owner skill and hand off honestly?
    weight: 0.2
  - id: state
    prompt: Can a new session continue from local state without chat reconstruction?
    weight: 0.2
  - id: regression
    prompt: Are adjacent correct paths or non-goals explicitly protected?
    weight: 0.2
outputs:
  report_root: .hiq/eval/runs
  review_ingest: .hiq/changes/<id>/review.md
notes:
  - Eval availability does not make every change eval-required.
  - Record eval applicability, status, run path, and reason in current-change state.
"

# manifest always refresh structural fields lightly via temp if missing
if [[ ! -f "$HIQ/runtime-manifest.json" ]]; then
  cat >"$HIQ/runtime-manifest.json" <<EOF
{
  "framework": "hiq",
  "schema": 2,
  "mode": "init",
  "created_at": "$STAMP",
  "updated_at": "$STAMP",
  "codegraph": "pending",
  "stack": {},
  "runtime": {
    "config": ".hiq/config.yaml",
    "current_change": ".hiq/current-change.json",
    "eval_root": ".hiq/eval"
  }
}
EOF
  echo "created=$HIQ/runtime-manifest.json"
else
  echo "exists=$HIQ/runtime-manifest.json"
fi

write_if_absent "$ROOT/AGENTS.md" "# HiQ Project Rule

This repository requests \`hiq-auto\` as the first HiQ coordination layer for new conversations unless the user explicitly disables auto mode for the turn.

This file is an instruction contract, not proof that a host hook executed. The current automation capability must be reported from \`.hiq/current-change.json\`; a fresh project starts at \`instruction-only\` until the host provides verifiable stronger evidence.

## Required behavior

1. Treat \`hiq-auto\` as the outer coordination wrapper when the host loaded this project rule.
2. Keep the retained owner surface at 11.
3. Enter goal mode for normal work:
   - create or refresh \`.hiq/goals/<id>.md\`
   - lease ownership to the truthful current owner skill before meaningful work
   - append the owner transition after the step and refresh session/current-change/goal pointers
   - continue until \`hiq-review\` records current acceptance proof or a real blocker is recorded
4. Do not record \`hiq-review\` as owner unless a review artifact or acceptance matrix is being produced or refreshed.
5. Treat \`review.eval_enabled\` as capability only; record eval applicability and the actual run, or a reason that eval is not applicable.
6. Ask the user only for genuine decisions that local truth cannot answer.
7. If context pressure rises or a handoff is required, write a checkpoint first and mirror its path in session/current-change/goal state.
8. Keep durable verification commands current; mark stale or unrunnable commands instead of preserving deleted paths.
"

if { ! grep -q '^# HiQ Project Rule' "$ROOT/AGENTS.md" 2>/dev/null || ! grep -q 'hiq-auto' "$ROOT/AGENTS.md" 2>/dev/null; } && [[ "$CURRENT_PREEXISTED" == false && "$SESSION_PREEXISTED" == false ]]; then
  sed 's/"hostAutomationEvidence": "AGENTS.md"/"hostAutomationEvidence": null/' "$HIQ/current-change.json" >"$HIQ/current-change.json.tmp"
  mv "$HIQ/current-change.json.tmp" "$HIQ/current-change.json"
  sed 's/- \*\*host_automation_evidence\*\*: `AGENTS.md`/- **host_automation_evidence**: none/' "$HIQ/session.md" >"$HIQ/session.md.tmp"
  mv "$HIQ/session.md.tmp" "$HIQ/session.md"
  echo "warning=existing AGENTS.md is not a HiQ rule; hostAutomationEvidence=none"
fi

# profile gitignore hint at repo root
if [[ -f "$ROOT/.gitignore" ]]; then
  if ! grep -q '\.hiq/profile' "$ROOT/.gitignore" 2>/dev/null; then
    echo "" >>"$ROOT/.gitignore"
    echo "# HiQ private profile" >>"$ROOT/.gitignore"
    echo ".hiq/profile/" >>"$ROOT/.gitignore"
    echo "updated=$ROOT/.gitignore (+.hiq/profile/)"
  fi
fi

echo "done root=$ROOT hiq=$HIQ"
