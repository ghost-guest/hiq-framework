# HiQ Project Rule

This repository requests `hiq-auto` as the first HiQ coordination layer for new conversations unless the user explicitly disables auto mode for the turn.

This file is an instruction contract, not proof that a host hook executed. Fresh project state reports `hostAutomationLevel=instruction-only` and `autoStatus=available` until a host provides verifiable stronger evidence.

## Required behavior

1. `hiq-auto` is the outer coordination wrapper for this repo when the host loaded the project rule.
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
   - lease the truthful current owner before meaningful work
   - append owner transitions and refresh goal/session/current-change pointers after the step
   - continue until `hiq-review` records current acceptance proof or a real blocker is recorded
4. Do not record `hiq-review` as owner unless review.md or its acceptance matrix is being produced or refreshed.
5. Update `.hiq/session.md` and `.hiq/current-change.json` after meaningful owner changes.
6. Ask the user only for genuine product or business decisions that local repo truth cannot answer.
7. If context pressure rises or a handoff is required, write a checkpoint first and mirror it in session/current-change/goal state.
8. Keep verify_commands current; stale or unrunnable paths must be marked instead of preserved.

## Manual override

- If the user explicitly asks for one retained skill for one turn, allow it.
- After that turn, restore `hiq-auto` as the outer coordinator unless the user disabled auto mode.
