# Claude HiQ Auto Hook

Claude host adapter for HiQ.

Installed layout:

- `~/.claude/hooks/hiq-auto/user-prompt-submit.sh|cmd|ps1`
- `~/.claude/hooks/hiq-auto/stop.sh|cmd|ps1`
- merged entries in `~/.claude/hooks/hooks.json`

Behavior:

- `UserPromptSubmit` fires `hiq-hook pre-session --host=claude --adapter=claude`
- if the project is HiQ-managed and no active goal exists yet, it runs `hiq-activate --if-needed`
- `Stop` fires `hiq-hook pre-final --host=claude --adapter=claude`

This adapter does not claim `persistent` automation by itself. It proves `turn-scoped` execution through hook evidence under `.hiq/hooks/runs/`.
