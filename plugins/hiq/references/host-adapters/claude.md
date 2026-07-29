# Claude Adapter

Claude is a first-class HiQ host target.

## Runtime model

- Skills install to `~/.claude/skills/`
- Hook glue installs to `~/.claude/hooks/hiq-auto/`
- `~/.claude/hooks/hooks.json` is merged with HiQ `UserPromptSubmit` and `Stop` commands

## Recommended event mapping

- `UserPromptSubmit` -> `pre-session --host=claude --adapter=claude`
- `UserPromptSubmit` -> `hiq-activate --if-needed --host=claude --hook-adapter=claude`
- optional tool/action boundaries -> `pre-tool` / `post-tool`
- `Stop` -> `pre-final --host=claude --adapter=claude`

## Install

```bash
bash plugins/hiq/scripts/install-skills.sh claude
```

Windows:

```cmd
plugins\hiq\scripts\install-skills.cmd claude
```

This installs:

- HiQ skills into `~/.claude/skills/`
- shared runtime scripts into `~/.hiq/scripts/`
- Claude hook bundle into `~/.claude/hooks/hiq-auto/`
- merged HiQ hook commands into `~/.claude/hooks/hooks.json`

## Skill discovery rule

When the current agent is Claude, HiQ should only scan `~/.claude/skills/` for task-specific helper skills unless the user explicitly asks for cross-host inspection.

Do not set `persistent` unless the Claude environment has a verified automatic lifecycle hook configuration and `hiq-doctor` can see recent hook run evidence.
