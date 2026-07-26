---
name: hiq-install
description: >-
  HiQ 宿主安装与运行时总控。它不做项目基线，而是负责把 11-skill 框架与 bundled
  codegraph-rs 安装/升级到目标宿主，预览与执行 host sync，修复部分损坏的 runtime copy，
  并吸收 Comet 风格的 `doctor` 健康探测：用真实健康检查证明 Agent 侧技能、`~/.hiq/bin`
  运行时、状态脚本与宿主副本可用。核心原则：先说清目标与影响，再 apply；安装完成，必须靠
  宿主健康证据证明，而不是“脚本跑过了”。
---

# hiq-install — 宿主安装 · Runtime 同步 · Doctor · 健康校验

## Owns

- Host target selection and install scope
- Preview vs apply discipline before mutation
- Retained skill copy install/upgrade into host directories
- Bundled `codegraph-rs` install into HiQ-managed runtime paths
- Reference/script/vendor sync for installed runtime copies
- Repair of partial or drifted host installs
- Post-install health verification and doctor-style diagnosis

## Modes

- `preview` — inspect target, paths, count, and planned mutations without changing the host
- `apply` — perform install or upgrade on the chosen host target
- `repair` — restore missing, partial, or drifted runtime pieces after a failed or stale install
- `sync` — refresh host/runtime copies after retained framework files changed in the repo
- `verify` — run health checks only and report readiness without reinstalling when not needed
- `doctor` — diagnose runtime drift, missing scripts, stale host copies, or unproven health

## First principle

```text
Do not mutate a host before the target, paths, and blast radius are explicit.
An install is not done because the script exited green.
An install is done when the intended host copies exist,
managed runtime paths are healthy,
and the agent can truthfully use the framework.
```

## Trigger signals

Use `hiq-install` when one or more are true:

- The user asks to install or upgrade HiQ on a machine or agent host
- A retained framework change now needs host/runtime sync
- `~/.liveagent/skills`, `~/.hiq/bin`, scripts, or references look stale or missing
- Bundled `codegraph-rs` must be installed or repaired in HiQ-managed paths
- The user asks for health, doctor, verify, or repair of the framework runtime
- The real blocker is host runtime readiness, not project bootstrap or product code

## Spec

```text
STATE classify:
  determine the honest mode:
    inspect only -> preview
    install or upgrade needed -> apply
    partial/broken host state -> repair
    repo framework changed and copies must refresh -> sync
    only health proof requested -> verify
    diagnosis of runtime drift or readiness -> doctor
  create or refresh `.hiq/changes/<id>/install.md`
  if the request is actually project baseline or repo bootstrap:
    route to hiq-init and stop

STATE detect_target:
  choose target host explicitly:
    liveagent | codex | claude | project
  record:
    target
    destination path
    managed runtime home
    whether writes are allowed in the current environment
  if target=project:
    require project dir
  if direct host writes are blocked in the current environment:
    stay truthful, switch to preview/doctor planning, and report the blocker

STATE survey_runtime:
  inspect only the install truth that matters:
    source repo paths under `plugins/hiq/skills`, `plugins/hiq/references`, `plugins/hiq/scripts`, `plugins/hiq/vendor`
    destination directories if readable
    managed runtime paths under `~/.hiq/`
    bundled codegraph version pin
    status/doctor script presence
  summarize counts / missing pieces / stale drift, not raw trees

STATE plan:
  state before mutation:
    mode
    target
    destination
    backups that will be created
    skills/references/scripts/vendor/runtime pieces affected
    codegraph action
    health checks to run after apply
  if this is preview mode:
    stop after the plan and next truthful command

STATE backup_rule:
  before overwriting an existing host skill copy:
    create timestamped backup exactly once per install wave
    record backup location in install.md
  do not promise safe rollback unless backup paths are real

STATE apply_or_repair:
  use the canonical installer path:
    macOS/Linux -> `install.sh` or `plugins/hiq/scripts/install-skills.sh`
    Windows -> `plugins/hiq/scripts/install-skills.cmd` or `plugins/hiq/scripts/install-skills.ps1`
  or equivalent truthful steps
  ensure these surfaces stay aligned:
    host skill copies
    `_hiq-references`
    `_hiq-scripts`
    `_hiq-vendor`
    `~/.hiq/scripts`
    `~/.hiq/vendor`
    `~/.hiq/bin/codegraph`
    `~/.hiq/scripts/hiq-status.sh`
    `~/.hiq/scripts/hiq-doctor.sh`
  if repair mode:
    replace only missing, stale, or broken runtime pieces instead of inventing unrelated mutations

STATE codegraph_runtime:
  treat bundled `codegraph-rs` as required, not optional
  verify install landed in HiQ-managed paths
  prefer managed launchers/scripts over random PATH assumptions
  if codegraph install fails but host skill copies succeeded:
    mark install partial, not green

STATE doctor:
  when mode=doctor or verify:
    inspect:
      destination exists and expected skill count is plausible
      references/scripts/vendor copies exist where required
      managed codegraph binary exists and reports healthy status when possible
      `hiq-run`, `hiq-status`, and `hiq-doctor` are present in managed script paths
      any preview/apply output used as evidence matches the actual destination
    use `hiq-doctor` style compact diagnostics; do not dump raw trees
    if environment blocks a health check:
      record exactly what was blocked and what remains unproven

STATE route:
  PASS -> record health summary and next owner (`hiq-session`, `hiq-init`, or `hiq-skill`)
  PARTIAL -> record missing proof or blocked writes and stay on `hiq-install`
  FAIL because host state is broken in a way not yet understood -> route to hiq-debug
```

## I/O

| Artifact | Path | Role |
|----------|------|------|
| Install state | `.hiq/changes/<id>/install.md` | target, mode, paths, backup, health, next action |
| Evidence | `.hiq/changes/<id>/evidence.md` | preview/apply/verify/doctor command summaries |
| Source of truth | `plugins/hiq/skills/`, `plugins/hiq/references/`, `plugins/hiq/scripts/`, `plugins/hiq/vendor/` | framework source to install |
| Host copies | `~/.liveagent/skills/...`, `~/.codex/skills/...`, `~/.claude/skills/...`, `<project>/.agents/skills/...` | installed skill surfaces |
| Managed runtime | `~/.hiq/bin`, `~/.hiq/scripts`, `~/.hiq/vendor` | bundled runtime assets |
| Output | install verdict + health evidence + next owner |

Template: `plugins/hiq/references/templates/install.md`

## Required install truths

`install.md` must preserve these recoverable fields:

- target host and destination path
- selected mode and why
- write permission / environment blockers
- planned or actual backup path
- expected vs installed skill/runtime surfaces
- codegraph version/source and runtime status
- status/doctor script presence
- verification commands and latest result
- next action and next owner skill

## Install rules

1. `hiq-install` is host/runtime work, not project bootstrap
2. Preview before apply when target or blast radius is not already explicit
3. Framework repo changes that affect installed surfaces must route through sync, not silent drift
4. Bundled `codegraph-rs` is mandatory for a healthy install
5. Backups are part of truthful rollback, not optional narration
6. Portable project configs must stay free of committed machine-absolute paths
7. If environment policy blocks host writes, say so and stop pretending sync happened
8. Doctor output must stay compact, comparable, and evidence-backed

## Announce

```text
install: <change-id>
mode: preview|apply|repair|sync|verify|doctor
target: liveagent|codex|claude|project
writes: allowed|blocked
codegraph: healthy|missing|partial
next: hiq-install | hiq-init | hiq-session | hiq-skill | hiq-debug
```

## Gates

- No host mutation before target/destination are explicit
- No green install claim without runtime health proof
- No project-init work smuggled into host install
- No host sync claim when current environment blocked writes
- No optional treatment of bundled codegraph runtime
- No doctor pass while key status scripts or managed runtime pieces are missing

## Anti-patterns

1. Run installer blindly without naming the real target host
2. Treat preview output as proof of applied sync
3. Ignore partial codegraph failure because skill copies landed
4. Overwrite host copies with no recorded backup path
5. Claim the runtime is healthy while key checks were blocked or skipped
6. Mix project bootstrap and host install until neither owner is truthful
7. Say doctor is green while `hiq-status` / `hiq-doctor` are not even installed

## Done

The intended host/runtime surfaces are installed or truthfully reported as blocked, bundled codegraph is healthy or explicitly partial, runtime doctor checks are green or honestly partial, and the next owner skill is explicit.
