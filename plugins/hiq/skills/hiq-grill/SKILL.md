---
name: hiq-grill
description: >-
  HiQ 最大的前置规划与定约 skill。吸收原 decision / clarify / brainstorm /
  architect / arch-scan / domain / interface / slice / planning：负责先验证本地事实，
  再做 Proceed / Research First / Defer 分流，按 tier 控制提问预算，静默启用多专家会诊，
  产出可批准的 `grill.md` 与 `IMPLEMENT.md`。它吸收 `to-spec` / `to-tickets` 的成熟做法：
  先综合当前事实写出 spec、尽早锁定测试 seam、再把执行拆成 vertical slices 与 blocking
  edges。核心原则：问题不清先定约，用户只回答真正属于用户的决策，不为仓库本地能验证的事实买单。
---

# hiq-grill — 立项 · 澄清 · 研究 · 架构 · 计划

## Owns

- Proceed / Research First / Defer triage
- Goal, scope, acceptance, non-goals, and constraint framing
- Local fact verification before asking the user
- Spec synthesis from current repo truth and conversation context
- Seam selection for behavior verification before ticketing
- Expert-council pressure on architecture, interface, domain, risk, and slices
- Design trade-off comparison and recommendation
- `grill.md` planning state and approved `IMPLEMENT.md` with ticket frontier
- Explicit handoff to `hiq-implement`, `hiq-debug`, or `hiq-evolve`

## Modes

- `triage` — decide whether the work should proceed now, research first, or defer
- `research` — narrow unknowns until a truthful plan becomes possible
- `grill` — build the actual plan, slices, and approval-ready contract
- `refresh` — re-open an existing plan because truth, scope, or acceptance changed
- `handoff` — pause or switch sessions without losing planning truth

## First principle

```text
Planning is not question-asking theater.
Verify local truth first.
Synthesize the spec from what is already known.
Ask only the highest-leverage user decision that the repo cannot answer.
No product coding starts until the contract is explicit enough to approve.
```

## Trigger signals

Use `hiq-grill` when one or more are true:

- The user goal is real, but the scope, acceptance bar, or plan is still unclear
- The next honest step depends on research, architecture, interface, or domain pressure
- Multiple viable approaches exist and the user may own the trade-off
- Execution started revealing plan drift and the contract must be refreshed
- The request needs a real `IMPLEMENT.md`, not ad hoc chat guidance

Do not use `hiq-grill` when the real blocker is unknown root cause; route to `hiq-debug`.
Do not keep work here once an approved plan exists and the honest next step is coding; route to `hiq-implement`.

## Spec

```text
STATE classify:
  detect mode:
    go/no-go or priority unclear -> triage
    unknowns block planning truth -> research
    enough truth exists to build the plan -> grill
    old plan drifted after new evidence -> refresh
    session/context switch during planning -> handoff
  create or refresh `.hiq/changes/<id>/grill.md`
  set question budget by tier:
    L0 -> prefer 0, hard max 1
    L1 -> 1
    L2 -> 3
    L3 -> 5

STATE inspect_local_truth:
  read the smallest truthful local set first:
    .hiq/session.md
    relevant spec / CONTEXT / docs
    codegraph context when shared symbols or contracts matter
    current code / tests / behavior / prior change notes
  separate:
    confirmed facts
    assumptions to verify
    true user-owned decisions
  never ask the user for facts the repo can answer

STATE synthesize_spec:
  turn the current request + local truth into a spec-sized planning summary
  do not re-interview the user for information already present in the repo or chat
  name:
    problem from the user's perspective
    target outcome from the user's perspective
    user-visible behaviors that must change
    major non-goals and constraints
  if the work is behavior-sensitive:
    sketch the highest useful test seam now

STATE expert_board:
  activate only relevant experts from `grill-experts.md`
  run the board silently:
    each expert gives support / blocker / user decision?
  chair merge:
    facts -> verify locally
    engineering choices -> recommend in plan
    product-owned trade-offs -> candidate question
  do not expose roundtable transcripts to the user

STATE triage:
  decide one of:
    Proceed
    Research First
    Defer
  Proceed when acceptance and next-owner path can be made explicit now
  Research First when one or more decisive unknowns still block honest planning
  Defer when the requested change is not worth planning yet or depends on external decisions

STATE frame_contract:
  define in `grill.md`:
    requested outcome
    smallest worthwhile result
    non-goals
    constraints
    seam / behavior sketch
    interfaces / modules / user paths under pressure
    current truth and open blockers
  if the work touches multiple real approaches:
    compare them and pick a recommendation
  prefer existing seams over new seams
  keep the number of seams as low as truthfully possible

STATE decision_gate:
  if a user-owned choice remains after local verification:
    ask exactly one highest-leverage decision question
    include recommendation + trade-off
    spend from the tier question budget
  if the choice is purely engineering-owned:
    recommend and continue without asking
  if the budget is exhausted and planning is still dishonest:
    return Research First or Defer instead of interrogating further

STATE plan_build:
  produce or refresh `.hiq/changes/<id>/IMPLEMENT.md`
  include at minimum:
    Goal
    Acceptance
    Current truth
    Spec / seam plan
    Expert review
    Path map / affected surfaces
    Failure-mode forecast
    Execution policy
    Vertical ticket slices with done-when and blocking edges
    Verification
    route on block
  default to thin end-to-end slices; only use a wide-refactor plan when vertical slices cannot stay green
  if domain terms or invariants became clearer:
    capture sediment for `.hiq/CONTEXT.md`

STATE approval_gate:
  stop for explicit approval of the current IMPLEMENT contract before L1+ product coding
  initial user intent to solve the problem != approval of the plan
  explicit L0 fast path may skip formal approval only when the change is truly local and reversible

STATE route:
  approved plan with coding next -> hiq-implement
  blocked by unknown cause instead of scope -> hiq-debug
  approved evolution goal with migration/refactor/perf/harden ownership -> hiq-evolve
  still missing decisive truth -> stay in hiq-grill as research or refresh

STATE handoff:
  summarize the current verdict, question budget used, active experts, blockers, plan status, and next owner
  point to grill.md, IMPLEMENT.md, and latest checkpoint/session pointer
```

## I/O

| Artifact | Path | Role |
|----------|------|------|
| Planning state | `.hiq/changes/<id>/grill.md` | facts, decisions, experts, blockers, plan status |
| Execution contract | `.hiq/changes/<id>/IMPLEMENT.md` | approval-ready plan, slices, verification, next route |
| Shared terms | `.hiq/CONTEXT.md` | durable domain sediment discovered during planning |
| Session pointer | `.hiq/session.md` | active change, latest checkpoint, next owner |
| Output | Proceed / Research First / Defer verdict, one decision question at most, or approved `IMPLEMENT.md` |

Templates:

- `plugins/hiq/references/templates/grill.md`
- `plugins/hiq/references/templates/IMPLEMENT.md`
- `plugins/hiq/references/grill-experts.md`
- `plugins/hiq/references/grill-playbook.md`

## Required planning truths

`grill.md` and `IMPLEMENT.md` must preserve these in recoverable form:

- the requested outcome and smallest worthwhile result
- confirmed facts vs still-open assumptions
- the synthesized spec summary and chosen seam / behavior boundary
- active experts and why they were relevant
- question budget used and any pending user decision
- non-goals, constraints, and interfaces under pressure
- recommended approach and rejected alternatives when they mattered
- slice frontier, blocking edges, done-when, and verification path
- route-on-block and next owner skill

## Planning rules

1. Facts are verified locally before they become user questions
2. One question per turn, and only for real user-owned trade-offs
3. Expert council improves the plan, not the amount of chatter
4. L0 stays short; do not force heavy architecture ceremony onto tiny reversible work
5. Synthesize the spec from known truth before asking for more discovery theater
6. Prefer one high seam and public behavior checks over many low-level test hooks
7. Default to vertical end-to-end slices; use wide-refactor planning only when slices cannot stay green
8. If acceptance is weak, the plan is not done even if the implementation idea feels obvious
9. When scope or truth changes midstream, refresh the contract instead of freelancing in chat

## Announce

```text
grill: <change-id>
mode: triage|research|grill|refresh|handoff
verdict: proceed|research-first|defer|approval-needed
questions: <used>/<budget>
experts: <active-set>
next: hiq-grill | hiq-implement | hiq-debug | hiq-evolve | hiq-session
```

## Gates

- No product coding before approved `IMPLEMENT.md` except explicit L0 fast path
- No fact-finding questions the repo can answer locally
- No expert-by-expert interrogation of the user
- No laundry-list planning dumps when one decisive question would do
- No pretending a vague plan is “good enough” because review can catch it later
- No stale chat memory standing in for `grill.md` or `IMPLEMENT.md`

## Anti-patterns

1. Ask five clarification questions before reading the codebase
2. Treat each expert as a separate user-facing speaker
3. Produce architecture prose with no acceptance or slice contract
4. Keep spending question budget on naming trivia while scope remains unclear
5. Start coding because the likely plan seems obvious even though the contract is still fuzzy
6. Hide plan drift inside implementation notes instead of reopening `hiq-grill`

## Done

A truthful Proceed / Research First / Defer verdict exists, or an approval-ready `IMPLEMENT.md` exists with explicit next-owner routing and no unresolved planning lie.