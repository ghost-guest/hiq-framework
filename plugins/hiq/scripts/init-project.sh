#!/usr/bin/env bash
# Mechanical .hiq skeleton for hiq-init (agent-run). Content fill is Agent's job.
set -euo pipefail

ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"
HIQ="$ROOT/.hiq"
STAMP="$(date +%Y-%m-%dT%H:%M:%S%z)"

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
  "$HIQ/eval/runs"

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
schema: 1
language: zh-CN
artifacts:
  root: .hiq
  session: .hiq/session.md
  current_change: .hiq/current-change.json
  eval_root: .hiq/eval
resume:
  prefer_local_state: true
  require_checkpoint_before_handoff: true
  status_command_posix: bash "\$HOME/.hiq/scripts/hiq-status.sh" .
  status_command_windows: '%USERPROFILE%\\.hiq\\scripts\\hiq-status.cmd .'
review:
  require_fresh_evidence: true
  eval_enabled: true
  eval_config: .hiq/eval/eval.yaml
auto:
  enabled: true
  entry_skill: hiq-auto
  goal_dir: .hiq/goals
  project_rule_file: AGENTS.md
  auto_resume: true
  require_review_acceptance: true
  allow_explicit_skill_override: true
skill:
  retained_count: 11
  stable_surface: true
install:
  managed_runtime_home: ~/.hiq
  doctor_command_posix: bash "\$HOME/.hiq/scripts/hiq-doctor.sh" .
  doctor_command_windows: '%USERPROFILE%\\.hiq\\scripts\\hiq-doctor.cmd .'
"

write_if_absent "$HIQ/current-change.json" "{
  \"framework\": \"hiq\",
  \"schema\": 1,
  \"activeChange\": null,
  \"phase\": \"idle\",
  \"ownerSkill\": \"hiq-session\",
  \"nextSkill\": \"hiq-session\",
  \"nextStep\": \"rebuild pointer or start the first truthful owner skill\",
  \"goalId\": null,
  \"goalPath\": null,
  \"goalNow\": \"\",
  \"acceptanceTarget\": \"\",
  \"latestCheckpoint\": null,
  \"updatedAt\": \"$STAMP\"
}
"

write_if_absent "$HIQ/session.md" "# Session

> Updated by \`\$hiq-session\`. This file is the compact-safe local resume packet.

## Pointer

- **started**: $STAMP
- **updated**: $STAMP
- **agent**:
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

- **goal_record**: \`.hiq/goals/<id>.md\` or none
- **goal_now**:
- **blockers**:
- **acceptance_target**:
- **verify_commands**:

## Code / Graph

- **codegraph_state**: missing
- **codegraph_anchors**:
- **last_green**:

## Resume Safety

- **latest_checkpoint**: none
- **compact_safe_summary**:

## History

- **last_action**: hiq-init skeleton created
- **next_action**: run hiq-session or the first truthful owner skill
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

write_if_absent "$HIQ/eval/eval.yaml" "schema: 1
name: hiq-local-eval
root: .
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

On every new conversation in this project, activate \`hiq-auto\` first unless the user explicitly disables auto mode for this turn.

## Required behavior

1. Treat \`hiq-auto\` as the outer automation wrapper.
2. Keep the retained owner surface at 11.
3. For normal work, enter goal mode:
   - create or refresh \`.hiq/goals/<id>.md\`
   - choose the truthful current owner skill
   - continue until \`hiq-review\` proves acceptance or a real blocker is recorded
4. Update \`.hiq/session.md\` and \`.hiq/current-change.json\` after meaningful owner changes.
5. Ask the user only for genuine decisions that local truth cannot answer.
6. If context pressure rises, checkpoint first, then resume through \`hiq-auto\`.
"

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
