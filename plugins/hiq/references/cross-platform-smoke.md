# HiQ Cross-Platform Smoke Matrix

This file defines the minimum verification pass for HiQ after any framework/runtime change.

Goal: prove that HiQ remains usable on macOS, Linux, and Windows without assuming one shell or one filesystem style.

## Scope

Run this smoke matrix when one or more of these changed:

- `plugins/hiq/scripts/`
- `plugins/hiq/skills/hiq-auto/`
- `plugins/hiq/skills/hiq-init/`
- `plugins/hiq/skills/hiq-install/`
- `plugins/hiq/references/templates/`
- host/runtime install behavior
- status / doctor / codegraph launch surfaces

## Acceptance

A smoke pass is acceptable only when all of these are true:

- project init can create a new `.hiq/` baseline
- project rule / auto entry is present after init
- status and doctor commands run from the platform-native entrypoint
- doctor reports `overall=partial` before CodeGraph init and `overall=ok` only after `.codegraph/` exists
- installed runtime copies include the expected scripts and skills
- no committed template forces machine-absolute paths or a single shell assumption

## Matrix

| Platform | Shell / runner | Required checks |
|----------|----------------|-----------------|
| macOS | `bash`, native terminal | init, install sync, status, doctor |
| Linux | `bash`, native terminal | init, install sync, status, doctor |
| Windows | `cmd` + PowerShell | init, install sync, status, doctor |

One-command smoke helpers:

```bash
bash plugins/hiq/scripts/hiq-smoke.sh
```

```bat
plugins\hiq\scripts\hiq-smoke.cmd
```

## 1. New project init

### macOS / Linux

```bash
rm -rf tmp/hiq-smoke-project
mkdir -p tmp/hiq-smoke-project
bash plugins/hiq/scripts/init-project.sh tmp/hiq-smoke-project
```

### Windows

```bat
rmdir /s /q tmp\hiq-smoke-project
mkdir tmp\hiq-smoke-project
plugins\hiq\scripts\init-project.cmd tmp\hiq-smoke-project
```

Must produce at minimum:

- `.hiq/BOOTSTRAP.md`
- `.hiq/config.yaml`
- `.hiq/current-change.json`
- `.hiq/session.md`
- `AGENTS.md`

Must also prove:

- `auto.entry_skill: hiq-auto`
- `goalId` / `goalPath` fields exist in `current-change.json`
- `goal_record` exists in `session.md`

## 2. Host/runtime install sync

### macOS / Linux

```bash
bash plugins/hiq/scripts/install-skills.sh liveagent '' 1
```

### Windows

```bat
plugins\hiq\scripts\install-skills.cmd liveagent "" 1
```

Must prove:

- retained skills are copied
- `hiq-auto` is copied
- `_hiq-scripts` / `_hiq-vendor` are refreshed
- managed runtime scripts are refreshed under `~/.hiq/scripts` or `%USERPROFILE%\.hiq\scripts`

## 3. Runtime probes

### macOS / Linux

```bash
bash "$HOME/.hiq/scripts/hiq-status.sh" .
bash "$HOME/.hiq/scripts/hiq-doctor.sh" .
```

### Windows

```bat
%USERPROFILE%\.hiq\scripts\hiq-status.cmd .
%USERPROFILE%\.hiq\scripts\hiq-doctor.cmd .
```

Expected:

- `session=ok` or truthful `missing` when run outside an initialized repo
- `overall=ok` for a healthy initialized repo
- no shell-not-found failure on Windows

## 4. Dispatcher checks

### macOS / Linux

```bash
bash plugins/hiq/scripts/hiq-run.sh init-project tmp/hiq-smoke-project
bash plugins/hiq/scripts/hiq-run.sh status .
```

### Windows

```bat
plugins\hiq\scripts\hiq-run.cmd init-project tmp\hiq-smoke-project
plugins\hiq\scripts\hiq-run.cmd status .
```

Must prove the dispatcher exposes these tasks truthfully:

- `init-project`
- `install-skills`
- `project-init`
- `status`
- `doctor`

## 5. Template portability checks

Search for bad committed assumptions after edits:

- machine-absolute paths in committed templates
- bash-only runtime instructions with no Windows peer for key runtime surfaces
- goal templates missing owner / acceptance / evidence tracking

Suggested checks:

```bash
git grep -n '/Users/' -- plugins/hiq .hiq README.md FRAMEWORK.md
```

```bash
git grep -n 'status_command_windows\|doctor_command_windows\|hiq-auto' -- plugins/hiq .hiq README.md FRAMEWORK.md
```

## 6. Known environment caveats

- A macOS or Linux host cannot fully runtime-test the Windows PowerShell scripts unless `pwsh` is installed or a Windows runner is available.
- A Windows host may still need GitHub / curl / PowerShell availability for codegraph installation, depending on the path taken.
- If a platform cannot be executed in the current environment, state that clearly; do not pretend the smoke pass is complete.

## Release note guidance

When a release includes runtime or portability changes, report smoke status in this form:

```text
smoke:
- macOS: passed
- Linux: not run in current environment
- Windows: source-complete, runtime not executed in current environment
```
