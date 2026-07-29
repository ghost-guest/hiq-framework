# Codex Adapter

Codex integration should wrap the available session/tool lifecycle with the host-neutral HiQ hook core. The adapter remains host-specific glue only; state truth stays in `.hiq/current-change.json`, `.hiq/session.md`, and `.hiq/hooks/runs/`.

Recommended event mapping:

- task/session start -> `pre-session --host=codex --adapter=codex`
- before shell/tool mutation -> `pre-tool --host=codex --adapter=codex --tool=<tool>`
- after shell/tool mutation -> `post-tool --host=codex --adapter=codex --tool=<tool>`
- before final response -> `pre-final --host=codex --adapter=codex`

Skill discovery rule:

- when the current agent is Codex, HiQ should only scan `~/.codex/skills/` for task-specific helper skills unless the user explicitly asks for cross-host inspection

If Codex cannot guarantee automatic lifecycle invocation in the current environment, the project remains `turn-scoped` only after a hook command actually runs. It should not claim `persistent` from instructions alone.
