---
name: hiq-auto
description: >-
  HiQ 自动编排入口。解决“每轮都要手动挑 skill、手动追状态、手动判断是否收工”的问题：
  在项目级规则触发或用户显式要求 auto / autopilot / goal / 端到端完成时，先进入 goal
  模式，持续在 retained 11 中选择当前真实 owner skill，直到 `hiq-review` 证明验收达标，
  或诚实记录阻塞与下一步。它不是第 12 个 retained owner；它是对 retained 11 的自动包装层。
---

# hiq-auto — 自动入口 · Goal 编排 · 直到验收

## Owns

- Project-level auto entry behavior for HiQ-managed repos
- Goal-first orchestration from user request to acceptance verdict
- Repeated truthful owner selection across the retained 11
- Keeping the outer loop alive until review-backed completion or explicit block
- Auto-rule persistence through `AGENTS.md`, `.hiq/config.yaml`, and `.hiq/goals/`
- Respecting explicit user overrides without losing the outer goal state

## Modes

- `auto` — default automatic entry for normal project work
- `goal` — create or refresh a durable goal record and drive it forward
- `continue` — resume an existing goal loop from local state
- `override` — let one retained skill own the next step while `hiq-auto` keeps the outer goal
- `handoff` — checkpoint the outer loop before session or agent switch

## First principle

```text
HiQ still has 11 retained owner skills.
`hiq-auto` does not replace them.
It keeps asking one question only:
"What is the truthful next owner step for this goal right now?"
Then it continues until acceptance is proven or a real blocker remains.
```

## Trigger signals

Use `hiq-auto` when one or more are true:

- The repo enables HiQ auto mode through project rules
- The user says auto, autopilot, goal, end-to-end, keep going, or finish the whole thing
- The user wants the framework to keep selecting the right HiQ skill step-by-step
- The main need is not one isolated lane, but continuous goal delivery until acceptance

Do not use `hiq-auto` when the user explicitly wants a single manual lane for one turn and does not want auto continuation afterward.
Do not treat `hiq-auto` as a new retained owner or a replacement for `hiq-review` acceptance proof.

## Spec

```text
STATE activate:
  if `.hiq/` baseline is missing:
    route first owner step to hiq-init
  ensure project auto rule exists in:
    AGENTS.md
    `.hiq/config.yaml` auto section
  write or refresh the auto-entry audit markers in `.hiq/session.md` and `.hiq/current-change.json`:
    entry skill = `hiq-auto`
    entry mode = auto | goal | continue | override | handoff
    auto status = active unless explicitly disabled/blocked/accepted
    manual override = none unless the user explicitly forced one owner lane
  decide mode:
    explicit auto / new request -> auto or goal
    existing goal record with open status -> continue
    explicit one-turn skill override -> override
    session switch / context pressure -> handoff

STATE rebuild_local_truth:
  read in order:
    AGENTS.md if present
    `.hiq/BOOTSTRAP.md`
    `.hiq/MEMORY.md`
    `.hiq/config.yaml`
    `.hiq/session.md`
    `.hiq/current-change.json`
    latest active `.hiq/changes/<id>/...`
    latest active `.hiq/goals/<id>.md` if present
  trust local files over chat reconstruction

STATE ensure_goal_record:
  create or refresh `.hiq/goals/<id>.md`
  record:
    requested outcome
    current goal statement
    non-goals
    acceptance target
    current outer status
    current truthful owner skill
    next owner skill
    blockers / user decision needed
    latest evidence gap
    owner transition ledger
    acceptance ledger
    evidence ledger
  if goal or acceptance is still unclear:
    choose hiq-grill as next owner
  if the work has no approved spec / seam / ticket frontier yet:
    choose hiq-grill as next owner
  preserve scope fidelity:
    the goal statement must keep the user's requested outcome intact
    staged delivery is allowed only when the user approved the staging boundary
    MVP / prototype / first-version / placeholder wording is a scope downgrade unless explicitly approved
    record any approved downgrade or staging decision in the goal user-decision ledger

STATE choose_owner:
  choose the single truthful retained owner step:
    host/runtime install or health issue -> hiq-install
    missing baseline or stale project bootstrap -> hiq-init
    resume/status/checkpoint/pointer rebuild -> hiq-session
    unclear scope/acceptance/plan/spec/ticket frontier -> hiq-grill
    unresolved user-owned inputs that affect acceptance -> hiq-grill or blocked
    approved implementation slice pending -> hiq-implement
    root cause unknown -> hiq-debug
    materially done, no user-owned acceptance blocker remains, but proof missing -> hiq-review
    refactor/migrate/perf/harden/retire/system goal -> hiq-evolve
    durable ADR/lesson/casebook/audit capture needed -> hiq-knowledge
    framework/skill governance change needed -> hiq-skill
    otherwise -> hiq
  append owner transition row into the goal ledger
  write owner + reason into goal record and session pointer
  mirror the same audit markers into `.hiq/current-change.json`:
    autoOwnerSkill
    autoReason
    manualOverride

STATE drive_step:
  activate the chosen owner skill for exactly the current honest step
  after that step completes, re-read local truth
  update:
    `.hiq/session.md`
    `.hiq/current-change.json`
    `.hiq/goals/<id>.md`
  refresh acceptance ledger and evidence ledger using the latest owner output
  ask:
    is the goal complete?
    are all acceptance items proven for this revision?
    is the next bottleneck now a different owner lane?

STATE loop:
  if acceptance is not yet proven and no explicit block exists:
    go back to choose_owner
  if the only blocker is a product/user decision:
    ask at most one focused decision question and wait
    after the answer, route back to hiq-grill to synthesize or refresh the plan before implementation
  if the work is blocked by external reality:
    record the block honestly and stop

STATE complete:
  completion requires hiq-review-backed proof
  only mark goal accepted when all are true:
    requested outcome is satisfied
    acceptance target is cleared
    non-goals were not silently violated
    review verdict is pass / ready
    session points to finish or next durable follow-up

STATE handoff:
  if session/context must switch before acceptance:
    write checkpoint
    store checkpoint path in session/current-change/goal record
    resume later through hiq-auto continue
```

## I/O

| Artifact | Path | Role |
|----------|------|------|
| Project rule | `AGENTS.md` | auto-load `hiq-auto` for new conversations when host honors AGENTS |
| Runtime config | `.hiq/config.yaml` | auto-mode flags and goal policy |
| Goal record | `.hiq/goals/<id>.md` | outer orchestration state, owner transition ledger, and completion bar |
| Session packet | `.hiq/session.md` | current truthful pointer for resumes, including whether `hiq-auto` entered and which owner it selected |
| Change pointer | `.hiq/current-change.json` | machine-readable next owner, goal state, and `hiq-auto` audit markers |
| Owner artifacts | `.hiq/changes/<id>/...` | grill / implement / debug / review / evolve / skill artifacts |
| Checkpoints | `context-checkpoints/<file>.md` | compact-safe handoff for long sessions |

Templates:

- `plugins/hiq/references/templates/AGENTS.md`
- `plugins/hiq/references/templates/goal.md`

## Gates

- Do not bypass `hiq-review` when claiming completion
- Do not keep looping after a real blocker is known; record it and stop honestly
- Do not ask the user repo-verifiable questions
- Do not expand the retained owner count; `hiq-auto` is a wrapper, not owner #12
- Do not ignore explicit user pause/stop/manual-lane instructions
- Do not let the outer goal drift after acceptance or non-goals changed; route back to planning truth first
- Do not silently downgrade a requested outcome into MVP, prototype, first-version, or placeholder work without an explicit user decision
- Do not route to `hiq-review` while real API data, workbooks, credentials, environments, or other user-owned acceptance inputs are still pending
- Do not treat a user answer as a plan; after a user-owned decision, refresh `grill.md` / `IMPLEMENT.md` before coding

## Announce

```text
auto-goal: <id>
mode: auto|goal|continue|override|handoff
owner_now: hiq-...
status: active|blocked|accepted|handoff
next: retained owner step | one user decision | checkpoint
```

## Anti-patterns

1. Treating `hiq-auto` as a magic skill that replaces planning, debugging, or review ownership
2. Declaring the goal done because code exists, without `hiq-review` acceptance proof
3. Auto-looping forever instead of stopping on a real external blocker or user-owned decision
4. Letting `hiq-auto` silently widen scope beyond the stated goal and non-goals
5. Adding auto mode without a durable goal record or session pointer
6. Sending a partially scaffolded or fixture-only result to review while the real accepted outcome still depends on missing user input

## Done

The project auto rule exists, the goal record is durable, each step routes to a truthful retained owner, the loop continues until acceptance is proven or honestly blocked, and future sessions can resume the same goal from local files instead of chat memory.
