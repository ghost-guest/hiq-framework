---
name: hiq
description: >-
  HiQ 唯一根路由与总调度器。只保留 11 个厚 skill：hiq / hiq-init / hiq-install /
  hiq-session / hiq-grill / hiq-implement / hiq-debug / hiq-review / hiq-evolve /
  hiq-knowledge / hiq-skill。任何开发请求先定级、定车道、定当前唯一主 skill，
  再 handoff。核心不是“列 skill 名单”，而是始终把请求送到最小且真实的下一步。
---

# hiq — 根路由 · 定级 · 车道选择 · 唯一主 skill

## Owns

- First classification of every incoming request
- L0 | L1 | L2 | L3 | Goal tiering
- Selecting the single current primary retained skill
- Ambiguity handling and one-question discipline
- Fast-path routing for simple work
- Preventing drift back into removed thin skills or external parallel frameworks

## Modes

- `route` — normal entry for unspecified development work
- `triage` — when the request is messy, mixed, or partially contradictory
- `resume-check` — when the user is continuing work and the first question is “where do we re-enter?”
- `handoff` — when the next retained skill is already obvious and should be activated cleanly

## First principle

```text
At any moment, HiQ should have one current primary skill.
Not three half-active skills, not a chain of thin aliases.
Choose the smallest truthful next skill and hand off cleanly.
```

## Routing priorities

Resolve in this order:

1. Explicit user-named retained skill, if it matches the real task
2. Host/framework bootstrap needs
3. Missing project baseline / session baseline needs
4. Bug / review / evolution / knowledge / skill-governance special lanes
5. General product work via grill -> implement -> review
6. One focused decision question only if the route is still not honest

## Tier guide

- `L0` — single-point, reversible, contract-stable, low coordination
- `L1` — local module work, some planning useful, still bounded
- `L2` — multi-file/module or contract-sensitive work
- `L3` — architecture/migration/long-running/high-risk/multi-owner work
- `Goal` — the user states a target outcome, but the work type is still mixed and must be classified further

## Spec

```text
STATE intake:
  read the latest user request only
  detect whether the user explicitly invoked one retained skill
  detect whether this is:
    host/framework work
    project init work
    session resume/finish/status work
    product work
    bug/debug work
    review/acceptance work
    evolution work
    knowledge capture work
    framework-governance work

STATE baseline_check:
  if the request is host/framework install, upgrade, verify, or doctor health:
    route hiq-install
    stop
  if the request is in a product repo and `.hiq/` baseline is missing:
    route hiq-init
    stop
  if the request is primarily about start/resume/finish/handoff/profile/checkpoint recovery/status/resume probe:
    route hiq-session
    stop

STATE special_lane_check:
  if root cause is unknown, bug is recurring, or regression mystery dominates:
    route hiq-debug
    stop
  if review, verify, check, demo, eval, release verdict, or fix-loop dominates:
    route hiq-review
    stop
  if refactor/migrate/perf/harden/retire/goal evolution dominates:
    route hiq-evolve
    stop
  if adr/lesson/casebook/audit capture dominates:
    route hiq-knowledge
    stop
  if skill governance / retained-skill thickening / absorb-vs-build / compose / eval / bundle / publish / framework sync dominates:
    route hiq-skill
    stop

STATE product_lane:
  classify tier L0-L3 or Goal
  if the request is direct low-risk coding and acceptance is already clear:
    route hiq-implement (L0 fast path)
    stop
  if coding is requested but IMPLEMENT/acceptance/scope are not yet trustworthy:
    route hiq-grill
    stop
  if architecture/research/interface/domain/planning uncertainty exists:
    route hiq-grill
    stop

STATE explicit_skill_guard:
  if user explicitly named a retained skill but the request semantics contradict it:
    do not obey blindly
    choose the truthful owner skill instead and say why in one short line

STATE ambiguity_gate:
  if two routes compete, ask:
    what is the real blocker right now?
  choose based on blocker priority:
    unknown cause -> hiq-debug
    unclear plan/acceptance -> hiq-grill
    ready coding -> hiq-implement
    proof/release -> hiq-review
  if still unresolved:
    ask one focused decision question only

STATE handoff:
  emit concise route summary:
    tier
    current lane
    chosen retained skill
    why now
    what the next skill must produce
  activate only one primary skill
  do not chain multiple new skills in one breath unless the next hop is structurally mandatory and immediate
```

## I/O

| Input | Source | Role |
|------|--------|------|
| User request | chat | primary routing signal |
| Project baseline status | `.hiq/`, `.codegraph/` | decide init/session paths |
| Active change artifacts | `.hiq/changes/<id>/...` | decide grill vs implement vs review vs knowledge |
| Session/checkpoint/runtime status | `.hiq/session.md`, `.hiq/current-change.json`, `context-checkpoints/` | decide resume lane |
| Output route summary | chat | tier + lane + chosen retained skill + reason |
| Durable state | `.hiq/` via target skill | root itself should write minimally; owner skill writes the contract |

## Fast-path rules

### L0 direct implement
Route straight to `hiq-implement` only when all are true:
- scope is narrow
- acceptance is already clear
- no meaningful architecture/research ambiguity exists
- no root-cause mystery exists

### Resume
Route to `hiq-session` first when the user is continuing work but the correct re-entry point is not obvious from the latest request.

### Review-first
Route to `hiq-review` first when the implementation is materially done and the main question is pass/fail, not how to code it.

## Gates

- Never route to removed thin skills
- Never activate parallel primary skills for one current step
- Never ask the user for facts that can be checked locally
- Never route into coding when planning/acceptance uncertainty is the real blocker
- Never let an explicit user skill name override the truthful owner when they conflict
- Never send framework work back into product-work skills if `hiq-skill` is the real owner

## Announce

```text
route: <retained skill>
tier: L0|L1|L2|L3|Goal
lane: init|session|grill|implement|debug|review|evolve|knowledge|skill
why: <one line>
next_output: <one line>
```

## Anti-patterns

1. Treating `hiq` as a dumb alias list instead of a real dispatcher
2. Sending unclear work directly into implementation because the user said “go code”
3. Starting debug when the real blocker is unclear acceptance or architecture
4. Asking many clarification questions instead of choosing the most truthful next owner skill
5. Routing to removed thin skills or external parallel frameworks
6. Letting multiple retained skills stay half-active with no clear primary owner

## Done

The request has one truthful current owner among the retained 11, the tier and lane are clear, and the next skill can continue without re-litigating the route.
