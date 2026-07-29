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

function Get-FullPath([string]$Path) {
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
}

$resolvedRoot = Get-FullPath $Root
$hiq = Join-Path $resolvedRoot ".hiq"
$stamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
$currentPreexisted = Test-Path -LiteralPath (Join-Path $hiq 'current-change.json')
$sessionPreexisted = Test-Path -LiteralPath (Join-Path $hiq 'session.md')

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
  status_command_posix: bash "$HOME/.hiq/scripts/hiq-status.sh" .
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
skill:
  retained_count: 11
  stable_surface: true
  compose_enabled: true
  bundle_enabled: true
  publish_enabled: true
install:
  managed_runtime_home: ~/.hiq
  doctor_command_posix: bash "$HOME/.hiq/scripts/hiq-doctor.sh" .
  doctor_command_windows: '%USERPROFILE%\\.hiq\\scripts\\hiq-doctor.cmd .'
  doctor_strict_posix: bash "$HOME/.hiq/scripts/hiq-doctor.sh" . --strict
  doctor_strict_windows: '%USERPROFILE%\\.hiq\\scripts\\hiq-doctor.cmd . --strict'
'@
Write-IfAbsent (Join-Path $hiq "config.yaml") $config

$current = @'
{
  "framework": "hiq",
  "schema": 2,
  "stateRevision": 1,
  "changeId": null,
  "stateStatus": "idle",
  "contentRevision": 0,
  "entrySkill": "hiq-auto",
  "entryMode": "auto",
  "hostTarget": "unknown",
  "hostAutomationLevel": "instruction-only",
  "hostAutomationEvidence": "AGENTS.md",
  "autoStatus": "available",
  "autoOwnerSkill": "hiq-session",
  "autoReason": "project rule is available; the host must load instructions before hiq-auto can coordinate this turn",
  "manualOverride": "none",
  "activeChange": null,
  "phase": "idle",
  "ownerSkill": "hiq-session",
  "nextSkill": "hiq-session",
  "nextStep": "rebuild pointer or start the first truthful owner skill",
  "goalId": null,
  "goalPath": null,
  "goalNow": "",
  "acceptanceTarget": "",
  "reviewStatus": "not-run",
  "reviewPath": null,
  "reviewedContentRevision": null,
  "acceptedAt": null,
  "evalApplicability": "not-applicable",
  "evalStatus": "not-applicable",
  "evalRunPath": null,
  "evalReason": "no active change",
  "checkpointRequired": false,
  "checkpointReason": "none",
  "resumeSource": "fresh",
  "latestCheckpoint": null,
  "verifyCommandsSource": ".hiq/session.md",
  "verifyCwd": ".",
  "verifyStatus": "unset",
  "verifyWaiverReason": "no verification command recorded",
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
- **state_revision**: 1
- **change_id**: none
- **state_status**: idle
- **content_revision**: 0
- **entry_skill**: `hiq-auto`
- **entry_mode**: auto
- **host_target**: unknown
- **host_automation_level**: instruction-only
- **host_automation_evidence**: `AGENTS.md`
- **auto_status**: available
- **auto_owner**: `hiq-session`
- **auto_reason**: project rule is available; the host must load instructions before hiq-auto can coordinate this turn
- **manual_override**: none
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
- **verify_commands_source**: `.hiq/session.md`
- **verify_cwd**: `.`
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
schema: 2
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

This repository requests `hiq-auto` as the first HiQ coordination layer for new conversations unless the user explicitly disables auto mode for the turn.

This file is an instruction contract, not proof that a host hook executed. The current automation capability must be reported from `.hiq/current-change.json`; a fresh project starts at `instruction-only` until the host provides verifiable stronger evidence.

## Required behavior

1. Treat `hiq-auto` as the outer coordination wrapper when the host loaded this project rule.
2. Keep the retained owner surface at 11.
3. Enter goal mode for normal work:
   - create or refresh `.hiq/goals/<id>.md`
   - lease ownership to the truthful current owner skill before meaningful work
   - append the owner transition after the step and refresh session/current-change/goal pointers
   - continue until `hiq-review` records current acceptance proof or a real blocker is recorded
4. Do not record `hiq-review` as owner unless a review artifact or acceptance matrix is being produced or refreshed.
5. Treat `review.eval_enabled` as capability only; record eval applicability and the actual run, or a reason that eval is not applicable.
6. Ask the user only for genuine decisions that local truth cannot answer.
7. If context pressure rises or a handoff is required, write a checkpoint first and mirror its path in session/current-change/goal state.
8. Keep durable verification commands current; mark stale or unrunnable commands instead of preserving deleted paths.
'@
Write-IfAbsent (Join-Path $resolvedRoot "AGENTS.md") $agents

$agentsPath = Join-Path $resolvedRoot 'AGENTS.md'
$agentsExistingText = Get-Content -LiteralPath $agentsPath -Raw
if (($agentsExistingText -notmatch '(?m)^# HiQ Project Rule' -or $agentsExistingText -notmatch 'hiq-auto') -and -not $currentPreexisted -and -not $sessionPreexisted) {
  $currentPath = Join-Path $hiq 'current-change.json'
  $currentText = Get-Content -LiteralPath $currentPath -Raw
  $currentText = $currentText.Replace('"hostAutomationEvidence": "AGENTS.md"', '"hostAutomationEvidence": null')
  [System.IO.File]::WriteAllText($currentPath, $currentText, [System.Text.UTF8Encoding]::new($false))
  $sessionPath = Join-Path $hiq 'session.md'
  $sessionText = Get-Content -LiteralPath $sessionPath -Raw
  $sessionText = $sessionText.Replace('- **host_automation_evidence**: `AGENTS.md`', '- **host_automation_evidence**: none')
  [System.IO.File]::WriteAllText($sessionPath, $sessionText, [System.Text.UTF8Encoding]::new($false))
  Write-Output 'warning=existing AGENTS.md is not a HiQ rule; hostAutomationEvidence=none'
}

$gitignore = Join-Path $resolvedRoot ".gitignore"
if (Test-Path -LiteralPath $gitignore) {
  $content = Get-Content -LiteralPath $gitignore -Raw
  if ($content -notmatch '(?m)^\.hiq/profile/$') {
    Add-Content -LiteralPath $gitignore -Value "`n# HiQ private profile`n.hiq/profile/"
    Write-Output "updated=$gitignore (+.hiq/profile/)"
  }
}

Write-Output "done root=$resolvedRoot hiq=$hiq"
