# HiQ Project Rule

This repository requests `hiq-auto` as the first HiQ coordination layer for new conversations unless the user explicitly disables auto mode for the turn.

This file is an instruction contract, not proof that a host hook executed. The current automation capability must be reported from `.hiq/current-change.json`; a fresh project starts at `instruction-only` until the host provides verifiable stronger evidence.

## Required behavior

1. Treat `hiq-auto` as the outer coordination wrapper when the host loaded this project rule.
2. Keep the retained owner surface at 11 (`hiq`, `hiq-init`, `hiq-install`, `hiq-session`, `hiq-grill`, `hiq-implement`, `hiq-debug`, `hiq-review`, `hiq-evolve`, `hiq-knowledge`, `hiq-skill`).
3. Enter goal mode for normal work:
   - create or refresh `.hiq/goals/<id>.md`
   - lease ownership to the truthful current owner skill before meaningful work
   - append the owner transition after the step and refresh session/current-change/goal pointers
   - continue until `hiq-review` records current acceptance proof or a real blocker is recorded
4. Do not record `hiq-review` as owner unless a review artifact or acceptance matrix is being produced or refreshed.
5. Treat `review.eval_enabled` as capability only; record eval applicability and the actual run, or a reason that eval is not applicable.
6. Ask the user only for genuine decisions that local truth cannot answer.
7. If context pressure rises or a handoff is required, write a checkpoint first and mirror its path in session/current-change/goal state.
8. Keep durable verification commands current; mark stale or unrunnable commands instead of preserving deleted paths.

## Manual override

- If the user explicitly asks for one retained skill for one turn, allow it.
- After that turn, restore `hiq-auto` as the outer coordinator unless the user disabled auto mode.
