# HiQ Project Rule

On every new conversation in this repository, activate `hiq-auto` first unless the user explicitly disables auto mode for this turn.

## Required behavior

1. `hiq-auto` is the outer automation wrapper for this repo.
2. The retained owner surface remains 11 skills:
   - `hiq`
   - `hiq-init`
   - `hiq-install`
   - `hiq-session`
   - `hiq-grill`
   - `hiq-implement`
   - `hiq-debug`
   - `hiq-review`
   - `hiq-evolve`
   - `hiq-knowledge`
   - `hiq-skill`
3. For normal work, `hiq-auto` must enter goal mode:
   - create or refresh `.hiq/goals/<id>.md`
   - choose the truthful current owner skill
   - continue until `hiq-review` proves acceptance or a real blocker is recorded
4. Update `.hiq/session.md` and `.hiq/current-change.json` after meaningful owner changes.
5. Ask the user only for genuine product or business decisions that local repo truth cannot answer.
6. If context pressure rises, checkpoint first, then resume through `hiq-auto`.

## Manual override

- If the user explicitly asks for one retained skill for one turn, allow it.
- After that turn, restore `hiq-auto` as the outer coordinator unless the user disabled auto mode.
