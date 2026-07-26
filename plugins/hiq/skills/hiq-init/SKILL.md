---
name: hiq-init
description: >-
  HiQ 项目基线总控。负责在目标 repo 建立 `.hiq/` 工程记忆、跨 Agent 续作所需的
  BOOTSTRAP / MEMORY / MAP / session / current-change、CodeGraph 索引与 portable MCP，
  以及吸收 Comet 风格的轻 runtime 状态与 eval scaffold。它不是宿主安装；宿主安装用
  `hiq-install`。用于新仓初始化、已有仓补建、旧框架迁移与续作准备。
---

# hiq-init — 项目基线 · Runtime 状态 · CodeGraph · Eval Scaffold

## Owns

- Project baseline skeleton under `.hiq/`
- Cross-agent resume packet and machine-readable current-change mirror
- Runtime config and evaluation scaffold
- Portable CodeGraph install, init, index, and MCP wiring
- Refreshing missing files in existing repos without clobbering user memory
- Absorbing legacy runtimes into HiQ directory structure
- Verifying that a brand new session can continue from local files alone

## Modes

- `init` — fresh repo or missing `.hiq/`
- `refresh` — existing `.hiq/`; fill gaps and refresh stale index/graph/runtime artifacts
- `absorb` — migrate legacy `.trellis` / `.do-it` / `.codestable` / `.assay` material into HiQ targets

## First principle

```text
A project is not initialized until:
1. local files can resume the work without chat history,
2. managed CodeGraph exists and is usable, and
3. runtime state/eval scaffold exist for future sessions and review.
```

## Trigger signals

Use `hiq-init` when any of these are true:

- The user asks to initialize a project or says `hiq init`
- A new repo needs HiQ baseline files and CodeGraph
- `.hiq/` is missing, incomplete, or stale
- Legacy frameworks need to be absorbed into HiQ
- The current repo should become safe for new-agent continuation and later eval/review work

## Spec

```text
STATE detect_root:
  locate the project root (git root or cwd with package/manifest)
  if the request is for host/framework installation rather than a product repo:
    route to hiq-install and stop

STATE classify:
  if no .hiq/ exists:
    mode = init
  else if user wants to fill gaps or refresh stale baseline files:
    mode = refresh
  else if legacy runtime folders are present and user wants migration:
    mode = absorb
  else:
    mode = refresh

STATE survey:
  read only the local truth that matters:
    README / package manifests / test scripts / lint scripts
    AGENTS.md / CLAUDE.md / docs/
    legacy runtime folders
    existing .codegraph/ and graph artifacts
    existing .hiq/config.yaml / current-change.json / eval/
  summarize, do not dump large trees

STATE plan:
  preview exactly what will be created or updated
  include baseline files, runtime state files, eval scaffold, graph files, CodeGraph actions, and absorb mapping
  if .hiq/ exists, never promise to overwrite non-empty memory files without confirm

STATE skeleton:
  create or refresh mechanical `.hiq/` structure via script or equivalent writes
  ensure at minimum:
    BOOTSTRAP.md
    CONTEXT.md
    MEMORY.md
    MAP.md
    attention.md
    config.yaml
    current-change.json
    session.md
    spec/index.md
    graph/
    eval/eval.yaml
    eval/runs/
    runtime-manifest.json

STATE fill:
  write durable content into:
    BOOTSTRAP.md — entry order, verify commands, runtime probes, resume contract
    CONTEXT.md — product, users, invariants, glossary, non-goals
    MEMORY.md — durable notes, conventions, active work, lessons
    MAP.md — top-level modules / owners / entry points
    config.yaml — runtime defaults for resume/review/install
    current-change.json — machine-readable pointer for status/resume
    session.md — human-readable pointer and next step
    spec/index.md — verify/lint/test seed
    graph/modules.md and graph/edges.md — human-readable module navigation
    eval/eval.yaml — local evaluation scaffold that hiq-review can ingest later
    runtime-manifest.json — version, mode, stack, CodeGraph status, runtime state timestamps

STATE codegraph:
  always use the HiQ-managed binary path, never random PATH resolution
  for the HiQ scaffold itself:
    on macOS/Linux use `hiq-run.sh init-project <root>` or `init-project.sh <root>`
    on Windows prefer `hiq-run.cmd init-project <root>` or `init-project.cmd <root>`
  for the CodeGraph step:
    on macOS/Linux use `hiq-run.sh project-init <root>` or `codegraph-project-init.sh <root>`
    on Windows prefer `hiq-run.cmd project-init <root>` or `codegraph-project-init.cmd <root>`
  the CodeGraph step must:
    install managed binary if missing
    initialize `.codegraph/`
    index the repo
    wire portable MCP using project-relative launcher paths
    avoid machine-absolute paths in committed configs
    ignore TTY/agent-UI failures if `.codegraph/` was successfully created
    fail only if the binary cannot be installed or `.codegraph/` cannot be created

STATE MCP_apply:
  if LiveAgent is in play, apply `.hiq/graph/mcp-liveagent.json` via McpManager
  ensure the applied MCP command is portable (`.hiq/tools/codegraph` or `.hiq/tools/codegraph.cmd`)
  never use bare PATH `codegraph` when the managed launcher exists
  never commit absolute workspace paths into `.mcp.json` or `.cursor/mcp.json`

STATE absorb_legacy:
  map legacy content into HiQ targets:
    `.trellis/spec/**` -> `.hiq/spec/**`
    trellis tasks / prd -> `tasks/` / `requirements/` / `changes/`
    `.do-it/CONTEXT.md` -> `CONTEXT.md` + `MEMORY.md`
    `.do-it/grill/**` -> `grill/**`
    `.codestable/**` -> changes / adr / knowledge
    `.assay` knowledge/adrs -> knowledge / adr
    Comet-style status/eval assumptions -> `config.yaml` / `current-change.json` / `eval/`
  do not delete legacy roots unless the user explicitly orders it

STATE verify:
  require all of the following:
    required .hiq files exist and are readable
    BOOTSTRAP points to MEMORY / config / session / current-change / codegraph
    managed `codegraph` binary exists
    `.codegraph/` exists and `codegraph status` is sane
    portable MCP artifacts were written or refreshed
    eval scaffold exists
  if any prerequisite fails, report failure instead of pretending init succeeded

STATE report:
  summarize created / updated files
  name the stack and the CodeGraph state
  name the binary path or install location
  name the runtime probes (`hiq-status`, `hiq-doctor`)
  name the next skill: usually `hiq-session` or the first real task skill
```

## I/O

| Input | Source | Role |
|------|--------|------|
| Repo root | cwd / git root / project path | determine the project to initialize |
| Local docs and manifests | README, package files, docs/ | capture project truth |
| Legacy runtime folders | `.trellis`, `.do-it`, `.codestable`, `.assay` | absorb mapping input |
| CodeGraph state | `.codegraph/`, `codegraph status` | baseline and graph truth |
| Output | `.hiq/`, `.codegraph/`, portable MCP configs | project baseline and future resume state |

## Templates and helpers

- `plugins/hiq/references/templates/BOOTSTRAP.md`
- `plugins/hiq/references/templates/session.md`
- `plugins/hiq/references/templates/config.yaml`
- `plugins/hiq/references/templates/current-change.json`
- `plugins/hiq/references/templates/eval.yaml`
- `plugins/hiq/scripts/init-project.sh`
- `plugins/hiq/scripts/init-project.cmd`
- `plugins/hiq/scripts/init-project.ps1`
- `plugins/hiq/scripts/hiq-run.sh`
- `plugins/hiq/scripts/hiq-run.cmd`
- `plugins/hiq/scripts/hiq-status.sh`
- `plugins/hiq/scripts/hiq-status.cmd`
- `plugins/hiq/scripts/hiq-status.ps1`
- `plugins/hiq/scripts/hiq-doctor.sh`
- `plugins/hiq/scripts/hiq-doctor.cmd`
- `plugins/hiq/scripts/hiq-doctor.ps1`
- `plugins/hiq/scripts/codegraph-project-init.sh`
- `plugins/hiq/scripts/codegraph-project-init.cmd`
- `plugins/hiq/scripts/install-codegraph.sh`
- `plugins/hiq/scripts/install-codegraph.cmd`

## Gates

- Never overwrite non-empty `CONTEXT.md`, `MEMORY.md`, or `BOOTSTRAP.md` without backup plus explicit confirm
- Never delete legacy directories unless the user explicitly orders it
- Never commit secrets into MEMORY
- Never install host skills here
- Never tell the user to manually run `codegraph init`
- Never use a managed-init route that can silently fall back to an untrusted PATH binary
- Never write machine-absolute paths into committed MCP configs
- Never call the repo initialized while runtime state or eval scaffold is still missing

## Done

- `.hiq/BOOTSTRAP.md`, `MEMORY.md`, `MAP.md`, `config.yaml`, `current-change.json`, `session.md`, and `runtime-manifest.json` exist
- `.hiq/eval/eval.yaml` exists
- `.codegraph/` is initialized and indexed
- managed codegraph binary exists under HiQ-controlled location
- BOOTSTRAP is enough for a brand new session to continue
- legacy mappings are recorded when absorb mode is used
- next step is named, usually `hiq-session` or the first real task skill

## Anti-patterns

1. Creating only empty stubs and calling the repo initialized
2. Overwriting project memory files without confirm or backup
3. Leaving `.codegraph/` missing or stale after claiming init is done
4. Letting a random PATH `codegraph` shadow the managed binary
5. Asking the user to run the init steps manually
6. Forgetting runtime state or eval scaffold while claiming Comet-style continuity already exists
7. Refreshing the baseline but leaving `current-change.json` and `session.md` out of sync

## Announce

```text
init: <mode>
root: <path>
codegraph: <ok|missing|stale>
runtime_state: <ok|missing|stale>
eval_scaffold: <ok|missing|stale>
next: hiq-session | first task
```
