# HiQ Project Rule

On every new conversation in this project, activate `hiq-auto` first unless the user explicitly disables auto mode for this turn.

## Required behavior

1. Treat `hiq-auto` as the outer automation wrapper.
2. Keep the retained owner surface at 11 (`hiq`, `hiq-init`, `hiq-install`, `hiq-session`, `hiq-grill`, `hiq-implement`, `hiq-debug`, `hiq-review`, `hiq-evolve`, `hiq-knowledge`, `hiq-skill`).
3. Enter goal mode for normal work:
   - create or refresh `.hiq/goals/<id>.md`
   - choose the truthful current owner skill
   - continue until `hiq-review` proves acceptance or a real blocker is recorded
4. Update `.hiq/session.md` and `.hiq/current-change.json` after meaningful owner changes.
5. Ask the user only for genuine decisions that local truth cannot answer.
6. If context pressure rises, checkpoint first, then resume through `hiq-auto`.

## Manual override

- If the user explicitly asks for one retained skill for one turn, allow it.
- After that turn, restore `hiq-auto` as the outer coordinator unless the user disabled auto mode.
