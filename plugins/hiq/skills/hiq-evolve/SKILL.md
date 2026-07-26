---
name: hiq-evolve
description: >-
  HiQ 系统演进总控。吸收原 refactor / migrate / perf / harden / retire / goal：
  当目标不是新增功能、也不是单纯 bug 修复，而是让系统更快、更稳、更安全、更清晰，
  或平滑迁移/退役旧路径时使用。核心不是“改一改”，而是先固定 baseline、成功指标、
  不可回退边界、rollout/rollback 现实，再把执行与验收路由给正确 owner。
---

# hiq-evolve — 重构 · 迁移 · 性能 · 加固 · 退役 · 目标

## Owns

- Evolution framing for refactor, migrate, perf, harden, retire, and explicit goals
- Baseline truth before change
- Success metric and must-not-regress boundary
- Rollout, rollback, containment, and compatibility planning
- Honest routing between planning, execution, debug, and proof owners
- Evolution-specific evidence expectations for release

## Modes

- `refactor` — behavior-equivalent structural improvement
- `migrate` — technology, protocol, data, or runtime transition
- `perf` — measurable latency, throughput, cost, or footprint improvement
- `harden` — reliability, security, resilience, or observability strengthening
- `retire` — removal of legacy, compatibility, or dead paths
- `goal` — an explicit target condition that still needs the correct evolution shape
- `handoff` — pause or switch sessions without losing baseline, risk, or rollout truth

## First principle

```text
Evolve work must name both:
1. what must improve
2. what must not regress
If either side is vague, it is not honest evolution yet.
```

## Trigger signals

Use `hiq-evolve` when one or more are true:

- The user wants a refactor, migration, perf improvement, hardening pass, retirement, or system-level goal
- The work changes how the system is structured or operated more than it changes product scope
- Rollout, rollback, compatibility, or measurement truth matters as much as the code change itself
- The right next step is not root-cause debugging or feature planning, but managing an evolution contract

Do not use `hiq-evolve` for ordinary feature implementation with stable requirements; route to `hiq-implement` after `hiq-grill`.
Do not use `hiq-evolve` when the main blocker is unknown failure cause; route to `hiq-debug`.

## Spec

```text
STATE classify:
  detect mode from the dominant pressure:
    structural cleanup with behavior preservation -> refactor
    source->target transition with compatibility or cutover -> migrate
    measurable system improvement -> perf
    trust/reliability/observability/risk reduction -> harden
    remove legacy or dead path -> retire
    explicit target condition but mixed path -> goal
    session/context switch during evolution -> handoff
  create or refresh `.hiq/changes/<id>/evolve.md`
  if scope, acceptance, or trade-offs are still not trustworthy:
    route to hiq-grill first

STATE baseline:
  establish current truth before edits:
    current behavior or compatibility boundary
    current metric / risk / debt / failure mode
    owning modules and codegraph hotspots
    current rollout and rollback reality
    nearest protected good paths
  write the baseline into evolve.md
  if baseline cannot be named, the work is not ready to execute

STATE mode_contract:
  refactor:
    define equivalence boundary
    identify characterization proof or smoke coverage
  migrate:
    define source -> target, compatibility window, cutover moment, rollback path
  perf:
    define baseline metric, target metric, workload shape, measurement command
  harden:
    define threat/failure class, boundary, guard, containment, observability signal
  retire:
    define old path, replacement, proof it is dead or safely gated, removal condition
  goal:
    define target condition, how progress is measured, and which other mode it most resembles

STATE risk_model:
  record in evolve.md:
    irreversible edges
    operator touch points
    rollout shape
    rollback or containment path
    adjacent paths most likely to regress
  if irreversible action needs human decision:
    stop and route through hiq-grill for explicit approval

STATE execution_contract:
  require a truthful implementation path:
    evolve.md holds baseline, metric, rollback, and mode policy
    IMPLEMENT.md holds slices and execution route
    tasks.md / evidence.md hold execution and proof state
  if those contracts are stale:
    refresh planning before coding

STATE owner_route:
  if coding slices are ready:
    route hiq-implement
  if root cause becomes unclear during the work:
    route hiq-debug
  if architecture/interface/scope truth drifts:
    route hiq-grill
  keep hiq-evolve as the owner of the evolution contract even when execution is delegated elsewhere

STATE proof_expectation:
  define what hiq-review must later prove:
    refactor -> behavior equivalence still holds
    migrate -> target path works and rollback/cutover story is explicit
    perf -> same-workload measurement improved to target or honest delta
    harden -> named threat/failure class is reduced with evidence
    retire -> old path is dead, replaced, or safely removed
    goal -> target condition reached or current delta is explicit

STATE closeout:
  before release recommendation, ensure evolve.md records:
    final metric / outcome
    what stayed true
    residual risk
    rollback or follow-up state
  if context/session must switch:
    summarize the active mode, baseline, risk, execution owner, and proof owner
```

## I/O

| Artifact | Path | Role |
|----------|------|------|
| Evolution contract | `.hiq/changes/<id>/evolve.md` | baseline, target, rollback, mode-specific policy |
| Execution contract | `.hiq/changes/<id>/IMPLEMENT.md` | slices and coding route |
| Progress state | `.hiq/changes/<id>/tasks.md`, `.hiq/changes/<id>/notes.md` | execution progress and local observations |
| Evidence | `.hiq/changes/<id>/evidence.md` | fresh measurement or validation summaries |
| Session pointer | `.hiq/session.md` | current change, checkpoint, next owner |
| Output | evolution contract, routed execution, proof expectation, release posture |

Template:

- `plugins/hiq/references/templates/evolve.md`

## Required evolution truths

`evolve.md` and linked execution state must preserve these in recoverable form:

- current baseline and why it is the right baseline
- success metric or finish line
- must-not-regress boundary and protected paths
- rollout, rollback, or containment reality
- mode-specific risk and irreversible edges
- next execution owner and later proof owner
- latest measured or observed outcome
- residual risk and follow-up work

## Evolution rules

1. No baseline, no improvement claim
2. Equivalence is a contract, not a vibe; refactor must name what remains the same
3. Migration must carry rollout and rollback truth, not just target-state enthusiasm
4. Perf work must compare the same workload, not different anecdotes
5. Hardening must name the failure/threat class it reduces
6. Retirement must prove a path is dead, gated, or replaced before removal claims
7. If the real work becomes feature planning or debugging, route honestly to the right owner

## Announce

```text
evolve: <change-id>
mode: refactor|migrate|perf|harden|retire|goal|handoff
baseline: known|partial|missing
success_metric: <one line>
must_not_regress: <one line>
next: hiq-evolve | hiq-grill | hiq-implement | hiq-debug | hiq-review | hiq-session
```

## Gates

- No coding when success metric or must-not-regress boundary is still vague
- No “faster / cleaner / safer” claim without baseline and current evidence
- No migration without cutover and rollback reality
- No retire/remove claim without proof the old path is dead or contained
- No review-ready claim until the expected proof shape is explicit
- No evolution state living only in chat while evolve.md is stale

## Anti-patterns

1. Using evolve as a bucket for random unrelated improvements
2. Refactor that quietly changes behavior with no equivalence boundary
3. Perf claim with no same-workload baseline and target
4. Migrate with a target design but no rollout or rollback story
5. Harden with no named threat, failure class, or observability signal
6. Retire with no proof the legacy path is safe to remove
7. Goal work that never commits to a measurable finish line

## Done

The evolution objective, baseline, and regression boundary are explicit, execution is routed through the correct owner, and release/closeout can rely on real evidence instead of aspirational language.