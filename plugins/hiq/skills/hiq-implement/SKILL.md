---
name: hiq-implement
description: >-
  HiQ 正式施工总控。吸收原 feature / implement / before-dev / tdd /
  worktree / delegate：基于批准的 IMPLEMENT.md 按 slice 落代码，先装载 spec 与
  CodeGraph 上下文，按风险决定是否 red-first TDD、隔离 worktree、委派独立子任务，
  并在每个 slice 后用真实自查/自测与进度记录收口。核心原则：不越过批准契约施工，
  不把“代码写完”当成“这个 slice 已交付”。
---

# hiq-implement — 施工总控 · Slice 执行 · TDD · 隔离 · 委派

## Owns

- Execution against an approved `IMPLEMENT.md`
- Spec/context loading before code on L2+ work
- One-slice-at-a-time delivery and progress capture
- Risk-based red-first TDD
- Worktree isolation for risky or parallel edits
- Delegation of clearly independent subtasks
- Self-check evidence before route to review

## Modes

- `execute` — normal slice delivery on the current branch/worktree
- `tdd` — red-first behavior lock for risky logic or contract-sensitive changes
- `isolate` — move execution into an isolated worktree when blast radius or branch state demands it
- `delegate` — assign an independent slice or bounded subtask with an explicit return contract
- `handoff` — pause or switch sessions without losing execution truth

## First principle

```text
Do not code past the approved contract.
One slice at a time.
A slice is not done when code exists.
A slice is done when the promised outcome, checks, and recorded progress all agree.
```

## Trigger signals

Use `hiq-implement` when one or more are true:

- An approved `IMPLEMENT.md` exists and the next honest step is coding
- Scope and acceptance are already clear enough to execute a slice
- The task needs spec loading, shared-symbol mapping, or disciplined progress tracking before edits
- A risky implementation step needs red-first TDD, isolation, or bounded delegation
- Review is premature because the work itself is not yet implemented

## Spec

```text
STATE classify:
  require approved IMPLEMENT.md unless this is an explicit L0 fast path
  detect mode:
    normal slice work -> execute
    risky logic / contract lock needed -> tdd
    risky shared edits / dirty branch / long parallel work -> isolate
    independent bounded subtask -> delegate
    context/session switch during execution -> handoff
  create or refresh execution state under `.hiq/changes/<id>/`:
    tasks.md
    notes.md
    evidence.md

STATE load_contract:
  read IMPLEMENT in order:
    Goal
    Acceptance
    Current truth
    Expert review
    Path map / failure-mode forecast when present
    Execution policy
    Slices
    Verification
    Spec / CONTEXT to load before code
  load referenced `.hiq/spec/...` and relevant terms from `.hiq/CONTEXT.md`
  if IMPLEMENT is stale, unapproved, or missing done-when clarity:
    route back to hiq-grill

STATE choose_slice:
  select exactly one next unchecked slice unless the diff is truly one inseparable micro-change
  restate for the active slice:
    outcome
    touch set
    do / do-not-touch boundaries
    verify command
    done-when
  if scope drift appears before code starts:
    stop and route to hiq-grill

STATE map_and_preflight:
  use CodeGraph first on shared symbols, callers/callees, owning modules, and impact radius
  decide whether this slice needs:
    red-first TDD
    worktree isolation
    delegation
  if the real blocker is unknown root cause:
    route to hiq-debug
  if the real work is refactor/migrate/perf/harden/retire:
    route to hiq-evolve

STATE tdd_lock:
  when mode=tdd or risk warrants it:
    write the failing proof first
    confirm it fails for the right reason
    turn green with the smallest truthful implementation
    do not weaken the test to fit the code

STATE isolate:
  when mode=isolate:
    define why current branch/worktree is unsafe
    isolate the slice in a worktree or equivalent bounded environment
    record owned paths and merge-back conditions before broad edits

STATE delegate:
  delegate only when the subtask is independent enough to return with low merge ambiguity
  define before delegation:
    owned scope
    allowed paths
    stop condition
    required evidence
    exact return artifact
  verify delegated output against the active slice contract before accepting it

STATE implement:
  make the smallest change that satisfies the active slice
  prefer existing local patterns, helpers, and contracts
  keep edits inside approved acceptance and non-goals
  do not silently bundle unrelated refactors

STATE self_check:
  run in order:
    active slice verify command
    nearest regression lock for touched behavior
    any acceptance proof affected by this slice
  if a check fails:
    record the result in evidence.md / notes.md
    keep the slice open and continue honestly
    if cause becomes unclear, route to hiq-debug

STATE record_progress:
  update tasks.md with:
    active/completed slice status
    touched files
    checks run
    blockers / next action
  update notes.md with decisive implementation notes and graph anchors
  update evidence.md with fresh command summaries from this revision
  if IMPLEMENT truth changed materially during work:
    stop and send the contract back to hiq-grill instead of freelancing

STATE route:
  if more approved slices remain and current slice is green:
    continue hiq-implement on the next slice
  if implementation is complete and evidence is fresh enough for acceptance:
    route to hiq-review
  if hidden root-cause uncertainty appears:
    route to hiq-debug
  if scope/contract/acceptance drift appears:
    route to hiq-grill
  if context/session must switch:
    summarize active slice, checks, blockers, and next action for handoff
```

## I/O

| Artifact | Path | Role |
|----------|------|------|
| Execution contract | `.hiq/changes/<id>/IMPLEMENT.md` | approved coding plan and slice contract |
| Progress tracker | `.hiq/changes/<id>/tasks.md` | active slice state, checks, blockers, next action |
| Execution notes | `.hiq/changes/<id>/notes.md` | design deltas, graph anchors, local observations |
| Evidence | `.hiq/changes/<id>/evidence.md` | fresh self-check summaries for this revision |
| Session pointer | `.hiq/session.md` | active change, current lane, next owner |
| Output | code + updated slice state + honest route to next skill |

Template: `plugins/hiq/references/templates/IMPLEMENT.md`

## Required execution truths

`IMPLEMENT.md` and execution state must keep these recoverable:

- approved goal and acceptance
- exact active slice and next slice
- touched files / allowed scope
- spec and CONTEXT loaded before code
- CodeGraph anchors for shared-risk areas
- whether TDD, isolation, or delegation is required and why
- fresh verify commands and latest results
- blockers, route changes, and next owner

## Execution rules

1. One slice closes at a time; unfinished work stays visible in `tasks.md`
2. Shared-symbol edits need CodeGraph context before broad changes
3. L2+ work loads `.hiq/spec/...` before implementation
4. TDD is a risk tool, not a ceremony tax; use it when behavior lock matters
5. Isolation is required when the branch/worktree state makes merge ambiguity or regression risk too high
6. Delegation needs an explicit return contract; otherwise keep the slice local
7. If coding reveals a plan problem, return to `hiq-grill` instead of rewriting scope in place

## Announce

```text
implement: <change-id>
mode: execute|tdd|isolate|delegate|handoff
slice: <current-slice>
spec: loaded|missing
checks: pending|failing|passing
next: hiq-implement | hiq-review | hiq-debug | hiq-grill | hiq-session
```

## Gates

- No coding without an approved contract except explicit L0 fast path
- No multiple-slice drift hidden inside one “small” diff
- No checkbox completion before fresh self-checks pass
- No shared-risk edits without CodeGraph context
- No delegation without owned paths and required evidence
- No stale chat memory standing in for `tasks.md`, `notes.md`, or `evidence.md`

## Anti-patterns

1. Start coding because the idea feels obvious while `IMPLEMENT.md` is still fuzzy
2. Touch three slices and mark one checkbox
3. Skip spec/context loading on L2+ work because the file names look familiar
4. Use TDD performatively where no behavior lock is needed, or skip it where regressions are likely
5. Delegate vague work and accept the result without contract/evidence checks
6. Keep coding after acceptance or non-goals changed instead of routing back honestly

## Done

The active slice is implemented, fresh checks are recorded, progress state is truthful, and the next owner skill is explicit.