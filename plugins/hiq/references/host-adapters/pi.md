# Pi Adapter

Pi is a first-class HiQ host target.

## Runtime model

- Skills install to `~/.pi/agent/skills/`
- The recommended host adapter is a Pi extension under `~/.pi/agent/extensions/hiq-auto-hook/`
- The extension should fire the host-neutral hook core, not mutate HiQ state directly

## Recommended event mapping

- `session_start` -> `pre-session --host=pi --adapter=pi`
- first `before_agent_start` in a HiQ-managed repo -> `hiq-activate` if no active goal record exists yet
- `agent_settled` -> `pre-final --host=pi --adapter=pi`
- optional `tool_call` / `tool_result` -> `pre-tool` / `post-tool` when deeper per-tool evidence is needed
- context-pressure or handoff -> `checkpoint --host=pi --adapter=pi --context-pressure=high`

## Install

```bash
bash plugins/hiq/scripts/install-skills.sh pi
```

Windows:

```cmd
plugins\hiq\scripts\install-skills.cmd pi
```

This installs:

- HiQ skills into `~/.pi/agent/skills/`
- shared runtime scripts into `~/.hiq/scripts/`
- Pi extension scaffold into `~/.pi/agent/extensions/hiq-auto-hook/`

## Truth model

- Fresh init remains `instruction-only`
- A Pi extension that actually fires `hiq-hook` upgrades the project to `turn-scoped`
- Do not claim `persistent` without durable host-side lifecycle wiring plus recent run evidence under `.hiq/hooks/runs/`

## Skill discovery rule

When the current agent is Pi, HiQ should only scan `~/.pi/agent/skills/` for task-specific helper skills unless the user explicitly asks for cross-host inspection.

## Context-mode boundary

Pi extensions such as context-mode may still handle sub-agent routing, compaction, or large-output control.
HiQ owns:

- truthful owner selection
- goal ledger and acceptance ledger
- session/current-change persistence
- review-backed completion rules

Those responsibilities must not be silently absorbed by unrelated Pi extensions.
