param(
  [string]$Root = "."
)

$ErrorActionPreference = "Stop"

function Write-IfAbsent([string]$Path, [string]$Content) {
  if (Test-Path -LiteralPath $Path) {
    Write-Output "exists=$Path"
    return
  }
  $parent = Split-Path -Parent $Path
  if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
  Write-Output "created=$Path"
}

$resolvedRoot = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Root))
$hiq = Join-Path $resolvedRoot ".hiq"
$stamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"

$dirs = @(
  "requirements", "architecture", "adr", "spec", "grill", "tasks", "changes", "archive",
  "goals", "knowledge", "audits", "graph", "profile", "eval", "eval\runs"
)
foreach ($dir in $dirs) {
  New-Item -ItemType Directory -Path (Join-Path $hiq $dir) -Force | Out-Null
}

$bootstrap = @'
# Project Bootstrap

> Any new agent/tool: read this file first, then MEMORY.md, config.yaml, and session.md.

## One-liner

(TODO: fill during hiq-init)

## Verify commands

```bash
# TODO: test / lint
```

## Read order

1. `.hiq/BOOTSTRAP.md` (this file)
2. `.hiq/MEMORY.md`
3. `.hiq/config.yaml`
4. `.hiq/session.md`
5. `.hiq/current-change.json`
6. `.hiq/MAP.md`
7. Active change under `.hiq/changes/` if any
8. Code map: `.hiq/graph/` + `codegraph status`

## Code intelligence

```bash
codegraph status
codegraph query <symbol>
codegraph callers <symbol>
codegraph impact <symbol>
codegraph context "<task>"
```

## Runtime probes

```bash
bash "$HOME/.hiq/scripts/hiq-status.sh" .
bash "$HOME/.hiq/scripts/hiq-doctor.sh" .
# Windows
%USERPROFILE%\.hiq\scripts\hiq-status.cmd .
%USERPROFILE%\.hiq\scripts\hiq-doctor.cmd .
```

## Resume

```text
$hiq-auto
# or: 继续 .hiq/BOOTSTRAP.md
# manual lane override: $hiq-session / $hiq-debug / ...
```
'@
Write-IfAbsent (Join-Path $hiq "BOOTSTRAP.md") $bootstrap

$context = @'
# Context

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
'@
Write-IfAbsent (Join-Path $hiq "CONTEXT.md") $context

$memory = @'
# Project Memory

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
'@
Write-IfAbsent (Join-Path $hiq "MEMORY.md") $memory

$map = @'
# Module Map

| Path | Role | Entry | Notes |
|------|------|-------|-------|
|      |      |       |       |

See also: `graph/modules.md`, `graph/edges.md`, CodeGraph index.
'@
Write-IfAbsent (Join-Path $hiq "MAP.md") $map

$attention = @'
# Attention

Short project conventions that drift easily.

-
'@
Write-IfAbsent (Join-Path $hiq "attention.md") $attention

$config = @'
framework: hiq
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
  status_command_posix: bash "$HOME/.hiq/scripts/hiq-status.sh" .
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
  doctor_command_posix: bash "$HOME/.hiq/scripts/hiq-doctor.sh" .
  doctor_command_windows: '%USERPROFILE%\\.hiq\\scripts\\hiq-doctor.cmd .'
'@
Write-IfAbsent (Join-Path $hiq "config.yaml") $config

$current = @'
{
  "framework": "hiq",
  "schema": 1,
  "activeChange": null,
  "phase": "idle",
  "ownerSkill": "hiq-session",
  "nextSkill": "hiq-session",
  "nextStep": "rebuild pointer or start the first truthful owner skill",
  "goalId": null,
  "goalPath": null,
  "goalNow": "",
  "acceptanceTarget": "",
  "latestCheckpoint": null,
  "updatedAt": "__STAMP__"
}
'@.Replace("__STAMP__", $stamp)
Write-IfAbsent (Join-Path $hiq "current-change.json") $current

$session = @'
# Session

> Updated by `$hiq-session`. This file is the compact-safe local resume packet.

## Pointer

- **started**: __STAMP__
- **updated**: __STAMP__
- **agent**:
- **active_change**: none
- **phase**: idle
- **next_skill**: hiq-session
- **next_step**: rebuild pointer or start the first truthful owner skill

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
- **next_action**: run hiq-auto or the first truthful owner skill
'@.Replace("__STAMP__", $stamp)
Write-IfAbsent (Join-Path $hiq "session.md") $session

$specIndex = @'
# Spec index

## Verify

```bash
# filled by hiq-init from package scripts
```

## Layers

- (add package/layer indexes as project grows)

## Quality check pointers

- run lint/type/test before claim done
'@
Write-IfAbsent (Join-Path $hiq "spec\index.md") $specIndex

$graphReadme = @'
# Code knowledge layer

- **Authoritative symbol graph**: `.codegraph/` (CodeGraph)
- **Human/agent navigation**: `modules.md`, `edges.md`
- During feature/issue work, update `edges.md` when you learn new module couplings.
'@
Write-IfAbsent (Join-Path $hiq "graph\README.md") $graphReadme

$codegraphDoc = @'
# CodeGraph (Cleboost/codegraph-rs via HiQ)

Engine: https://github.com/Cleboost/codegraph-rs  
Always use HiQ launcher (auto-installs binary):

```bash
export PATH="$HOME/.hiq/bin:$PATH"
# or:
bash "$HOME/.hiq/scripts/codegraph.sh" <cmd>
# Windows:
%USERPROFILE%\.hiq\scripts\codegraph.cmd <cmd>

codegraph init                 # .codegraph/ + index
codegraph status
codegraph index
codegraph sync
codegraph query <name>
codegraph files
codegraph context "implement X"
codegraph serve --mcp
```

Repair binary:

```bash
bash "$HOME/.hiq/scripts/install-codegraph.sh"
# or from HiQ repo:
bash plugins/hiq/scripts/install-codegraph.sh
# Windows:
%USERPROFILE%\.hiq\scripts\install-codegraph.cmd
```

MCP: restart after first init so agents load `.codegraph/`.
'@
Write-IfAbsent (Join-Path $hiq "graph\CODEGRAPH.md") $codegraphDoc

$modules = @'
# Modules

| Module | Path | Responsibility | Key symbols |
|--------|------|----------------|-------------|
|        |      |                |             |
'@
Write-IfAbsent (Join-Path $hiq "graph\modules.md") $modules

$edges = @'
# Module edges

Record "change A -> check B" couplings discovered in development.

| From | To | Kind | Why |
|------|----|------|-----|
|      |    |      |     |
'@
Write-IfAbsent (Join-Path $hiq "graph\edges.md") $edges

$evalReadme = @'
# Eval

HiQ-native evaluation scaffold absorbed from the useful Comet ideas.

- config: `.hiq/eval/eval.yaml`
- reports: `.hiq/eval/runs/`
- review owner: `hiq-review`
- framework governance owner: `hiq-skill`
'@
Write-IfAbsent (Join-Path $hiq "eval\README.md") $evalReadme

$evalYaml = @'
schema: 1
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
'@
Write-IfAbsent (Join-Path $hiq "eval\eval.yaml") $evalYaml

$manifestPath = Join-Path $hiq "runtime-manifest.json"
if (-not (Test-Path -LiteralPath $manifestPath)) {
  $manifest = @'
{
  "framework": "hiq",
  "schema": 2,
  "mode": "init",
  "created_at": "__STAMP__",
  "updated_at": "__STAMP__",
  "codegraph": "pending",
  "stack": {},
  "runtime": {
    "config": ".hiq/config.yaml",
    "current_change": ".hiq/current-change.json",
    "eval_root": ".hiq/eval"
  }
}
'@.Replace("__STAMP__", $stamp)
  [System.IO.File]::WriteAllText($manifestPath, $manifest, [System.Text.UTF8Encoding]::new($false))
  Write-Output "created=$manifestPath"
} else {
  Write-Output "exists=$manifestPath"
}

$agents = @'
# HiQ Project Rule

On every new conversation in this project, activate `hiq-auto` first unless the user explicitly disables auto mode for this turn.

## Required behavior

1. Treat `hiq-auto` as the outer automation wrapper.
2. Keep the retained owner surface at 11.
3. For normal work, enter goal mode:
   - create or refresh `.hiq/goals/<id>.md`
   - choose the truthful current owner skill
   - continue until `hiq-review` proves acceptance or a real blocker is recorded
4. Update `.hiq/session.md` and `.hiq/current-change.json` after meaningful owner changes.
5. Ask the user only for genuine decisions that local truth cannot answer.
6. If context pressure rises, checkpoint first, then resume through `hiq-auto`.
'@
Write-IfAbsent (Join-Path $resolvedRoot "AGENTS.md") $agents

$gitignore = Join-Path $resolvedRoot ".gitignore"
if (Test-Path -LiteralPath $gitignore) {
  $content = Get-Content -LiteralPath $gitignore -Raw
  if ($content -notmatch '(?m)^\.hiq/profile/$') {
    Add-Content -LiteralPath $gitignore -Value "`n# HiQ private profile`n.hiq/profile/"
    Write-Output "updated=$gitignore (+.hiq/profile/)"
  }
}

Write-Output "done root=$resolvedRoot hiq=$hiq"
