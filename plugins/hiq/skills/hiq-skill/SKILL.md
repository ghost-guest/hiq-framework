---
name: hiq-skill
description: >-
  HiQ 框架治理与自进化总控。吸收原 skill-build / skill-upgrade：保留 skill 的加厚、
  薄 skill 能力吸收、schema 对齐、路由/目录/宿主同步都走这里，并内化 Comet 风格的
  skill harness 能力：compose / eval / bundle / publish。核心不是“再造 skill”，而是让
  HiQ 在保持 11-skill 稳定表面的前提下持续变强。
---

# hiq-skill — Skill 治理 · 加厚 · 吸收 · Compose · Eval · Bundle

## Owns

- Retained skill upgrades
- Thin-skill absorption into retained skills
- Rare new-skill proposal under explicit re-approval
- Skill schema and framework consistency
- Catalog / routing / replacement-map / changelog sync
- Host/runtime skill copy synchronization
- Skill composition, evaluation, bundling, and publish-readiness for the retained surface

## Modes

- `upgrade` — strengthen an existing retained skill
- `absorb` — fold a thin skill or scattered capability into a retained skill
- `compose` — define or refine a retained-skill composition/harness without expanding user-facing skill count
- `eval` — create or refresh evaluation hooks/rubrics for a skill or workflow surface
- `bundle` — prepare a coherent pack of skills/references/scripts for installation or distribution
- `publish` — verify that the framework surface is ready to ship externally without drift
- `build` — propose or create a new skill only when the current 11-skill set is proven insufficient
- `sync` — repair framework consistency across skill files, docs, routing, templates, and host copies

## First principle

```text
Default answer is not “add another skill”.
Default answer is:
1. strengthen an existing retained skill
2. absorb the capability as a mode / lens / phase / runtime artifact
3. keep the user-facing surface stable
```

## Trigger signals

Use `hiq-skill` when one or more are true:

- A retained skill is obviously too thin to carry its lifecycle responsibility
- Repeated work is leaking into ad hoc chat steps instead of a stable skill contract
- A removed thin skill still appears necessary, but should likely be absorbed instead of revived
- Skill docs, routing, replacement map, templates, scripts, and host copies have drifted apart
- The framework needs skill composition, evaluation, bundle, or publish governance
- A genuinely new capability cannot fit any retained skill without making routing dishonest

## Spec

```text
STATE intake:
  identify target capability / retained skill / drift
  collect evidence:
    user request
    repeated workflow pain
    missing gates
    missing artifacts/templates/scripts
    sibling-skill overlap
    install/runtime drift
  if the request is really product work, not framework work:
    route back to hiq / hiq-grill / hiq-implement

STATE classify:
  choose mode:
    upgrade -> retained skill is right owner but too thin
    absorb -> old or scattered capability should move into a retained skill
    compose -> useful harness behavior should live across existing retained skills
    eval -> framework needs a rubric/report path that hiq-review can consume
    bundle -> install/distribution pack needs to be coherent
    publish -> external-facing release/readiness question dominates
    build -> only if no retained skill can honestly own it
    sync -> implementation already changed; docs/host/routing lag behind

STATE governance_check:
  ask in order:
    what problem does this change solve?
    why can an existing retained skill or mode not already cover it?
    does this reduce or increase user-facing complexity?
    what stays stable after the change?
  if answers are weak:
    stop and refine instead of editing files

STATE contract:
  create/refresh a framework change contract:
    `.hiq/changes/<id>/skill-change.md`
  record:
    target skill or skill set
    mode
    problem
    decision
    alternatives rejected
    files to change
    user-facing trigger changes
    docs/routing/install sync requirements
    host sync requirements
    eval/bundle/publish implications when relevant
    risks / rollback

STATE design_rule:
  upgrade/absorb/compose path:
    prefer adding modes, gates, templates, scripts, and handoffs
    avoid multiplying user-facing names
  eval path:
    keep rubric/report assets under `.hiq/eval/` or `plugins/hiq/references/templates/`
    ensure hiq-review remains the proof owner
  bundle/publish path:
    keep retained skill names stable
    verify scripts/references/vendor install together cleanly
  build path:
    require explicit proof that all 11 retained skills are insufficient
    require user-facing trigger, role boundary, overlap analysis, migration impact
    require explicit human re-approval before expanding the stable set

STATE implement:
  edit smallest truthful set:
    target SKILL.md files
    needed references/templates/scripts
    README / FRAMEWORK / SKILL_CATALOG / CHANGELOG
    routing / replacement map / host copies if impacted
  keep durable state and examples under `.hiq/` or `plugins/hiq/references/`

STATE consistency_sweep:
  verify all changed surfaces agree on:
    skill name
    purpose
    modes
    outputs
    routing position
    retained-count policy
    runtime script names
    eval/bundle/publish contracts when added
  sync host/runtime copies when framework-facing skill files changed

STATE release_gate:
  no completion claim until all are true:
    schema sections exist
    overlap with sibling skills is explicit
    docs/catalog/changelog are aligned
    scripts/templates are aligned with skill contracts
    host/runtime sync is done where needed
    checkpoint captures the framework decision if the change was substantial
```

## I/O

| Artifact | Path | Role |
|----------|------|------|
| Framework change contract | `.hiq/changes/<id>/skill-change.md` | why this skill change exists and what must stay consistent |
| Skill source | `plugins/hiq/skills/<skill>/SKILL.md` | retained skill contract |
| Templates / references | `plugins/hiq/references/` | deep examples and artifact shapes |
| Scripts | `plugins/hiq/scripts/` | runtime helpers for install/status/doctor/eval support |
| Framework docs | `README.md`, `FRAMEWORK.md`, `SKILL_CATALOG.md`, `CHANGELOG.md` | top-level alignment |
| Host copies | `~/.liveagent/skills/...`, `~/.hiq/references/...`, `~/.hiq/scripts/...` | installed runtime consistency |

Template:

- `plugins/hiq/references/templates/skill-change.md`

## Build vs absorb rule

Choose `absorb` unless all of these are true:

- no retained skill can own the capability without becoming dishonest
- routing would become clearer, not noisier
- the new skill has a durable lifecycle role, not a temporary technique
- user re-approves expanding the stable framework surface

If any item is false, do not add a new retained skill.

## Gates

- Do not revive thin-skill sprawl
- Do not create a new skill when a mode/lens/phase/script on an existing retained skill is enough
- Do not edit only the target SKILL and forget catalog/routing/docs/host sync
- Do not change framework surface without stating what remains stable for users
- Large framework restructures require explicit user approval
- Do not let eval or bundle assets drift outside the retained-owner model

## Announce

```text
skill-change: <id>
mode: upgrade|absorb|compose|eval|bundle|publish|build|sync
owner: <retained skill>
user_surface: stable|changed
files: <n>
next: sync | review | checkpoint
```

## Anti-patterns

1. Solving every new need by minting another skill
2. Upgrading a skill in text only, with no routing/catalog/template/script sync
3. Reintroducing removed thin skills under slightly different names
4. Claiming a new skill is needed without overlap analysis against the retained 11
5. Editing framework files with no host/runtime sync plan
6. Letting README, FRAMEWORK, SKILL_CATALOG, scripts, and installed copies disagree
7. Treating skill composition as a second user-facing framework instead of an absorbed runtime capability

## Done

The framework change is justified, the retained surface stays coherent, every affected source of truth is aligned, and users do not have to relearn a fragmented skill map.
