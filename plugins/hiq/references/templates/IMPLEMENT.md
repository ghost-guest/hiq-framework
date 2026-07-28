# IMPLEMENT — <title>

> Single source for coding. After user approval, `hiq-implement` executes one slice at a time, loads the required spec/context before edits, and records fresh self-check evidence instead of relying on chat memory.

- **change**: `.hiq/changes/<id>/`
- **tier**: L0 | L1 | L2 | L3
- **status**: draft | approved | in-progress | done
- **approved_by_user**: no | yes (message ref)
- **owner_skill**: `hiq-implement`
- **default_mode**: execute | tdd | isolate | delegate
- **ticket_strategy**: vertical-slices | wide-refactor-exception
- **active_slice**: Slice N | none
- **grill**: `grill.md` (required before L1+ product work)
- **scope_downgrade_approved**: no | yes (message ref)
- **verify baseline**: see §10

## 1. Goal (one sentence)

## 1b. Scope fidelity / downgrade approval

- requested outcome preserved?: no | yes
- accepted complete result:
- staged delivery approved?: no | yes -> boundary:
- MVP / prototype / first-version / placeholder wording present?: no | yes -> approval source:
- user-owned inputs still pending:
- if pending inputs affect acceptance, route to: blocked | hiq-grill | scaffold-only follow-up

## 2. Non-goals

- 

## 3. Acceptance (testable)

- [ ] 
- [ ] 

## 4. Current truth (verified)

- repo facts:
- constraints:
- codegraph / hotspots:
- seams / public interfaces to test through:
- already-correct paths to protect:

## 4b. Spec / seam plan

- synthesized behavior summary:
- seam choice and why:
- public behavior lock:
- test boundary to avoid:

## 5. Approach (chosen)

**Selected:**

**Rejected alternatives:**

| option | why not |
|--------|---------|
| | |

## 5b. Expert review (council)

- **Active**: (e.g. PM, ARCH, BE, FE, QA, PERF)
- **Consensus**:
- **Dissent / watch**:
- **Engineering choices (no user ask)**:

## 6. Path map (L2+)

`producer -> contract -> transport -> state -> surface -> verification`

Or: N/A because ...

## 7. Failure-mode forecast (L2+)

| class | risk | mitigation |
|-------|------|------------|
| live-path / state-machine / contract / synthetic-proof / operator / evidence-drift | | |

## 8. Execution policy

- **Spec / CONTEXT to load before code**:
- **Seams / public behaviors to test through**:
- **Default mode**: execute | tdd | isolate | delegate
- **Ticket strategy**: vertical-slices | wide-refactor-exception
- **Frontier rule**: only take the next unblocked slice
- **Blocking edges / depends_on source**:
- **When red-first TDD is required**:
- **When isolation/worktree is required**:
- **Delegation candidates and owned paths**:
- **Stop and return to `hiq-grill` if**: contract is missing `grill.md`, acceptance changes, or scope downgrade lacks explicit approval
- **Stop and return to `hiq-debug` if**:

## 8b. Wide refactor exception (only if needed)

- why vertical slices cannot stay green:
- expand/contract or batch strategy:
- intermediate compatibility rule:
- final integrate-and-verify step:

## 9. Slices (vertical, ordered frontier)

### Slice 1 — <name>

- **mode**: execute | tdd | isolate | delegate
- **depends_on**: none | Slice N
- **outcome**:
- **touch**: `path/a`, `path/b`
- **preflight**: spec to load, graph anchors, tests to inspect, seam to use
- **do**:
- **don't**:
- **verify**: `command`
- **proof needed**:
- **done when**:
- **route on block**: hiq-debug | hiq-grill | hiq-evolve | hiq-session

### Slice 2 — ...

## 10. Verification (fresh commands)

```bash
# primary
```

```bash
# regression / secondary
```

## 11. Rollback / flags

## 12. Progress files

- `tasks.md`: slice status / blockers / next action
- `notes.md`: implementation notes / graph anchors / local decisions
- `evidence.md`: fresh command summaries from this revision

## 13. Out of scope for this change

## 14. Start command for agent

```text
$hiq-implement  # or: execute Slice 1 only; stop after self-check
```
