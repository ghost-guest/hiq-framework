# Grill — <title>

- **change**: `.hiq/changes/<id>/`
- **tier**: L0 | L1 | L2 | L3
- **mode**: triage | research | grill | refresh | handoff
- **status**: open | research-first | defer | ready-for-approval | approved | blocked
- **approved_by_user**: no | yes (message ref)
- **question_budget**: <used> / <max>
- **experts_active**: PM, ARCH, ...
- **updated**:

## 1. Problem frame

- requested outcome:
- accepted complete result:
- staged delivery approved?: no | yes -> boundary:
- scope downgrade approved?: no | yes -> exact approval source:
- non-goals:
- constraints:

## 2. Spec synthesis / seam sketch

- problem from user perspective:
- solution from user perspective:
- user-visible behaviors under change:
- highest existing seam to test through:
- new seam needed?: no | yes ->
- seam confirmed with user?: no | yes | n/a

## 3. Expert board (silent)

| expert | support / must-be-true | blocker / veto | user decision? |
|--------|------------------------|----------------|----------------|
| PM | | | no \| yes: ... |
| ARCH | | | |

## 4. Confirmed facts

| id | premise | evidence | status |
|----|---------|----------|--------|
| F1 | | path / command / symbol | confirmed \| refuted |

## 5. Decisions

| id | question | experts | options | recommendation | status | choice | plan updated? |
|----|----------|---------|---------|----------------|--------|--------|---------------|
| D1 | | PM+ARCH | A / B | A because... | open \| chosen \| deferred | | no \| yes |

## 6. Options / design pressure

| approach | why consider it | major risks | recommend? |
|----------|------------------|-------------|------------|
| A | | | yes \| no |

## 7. Open blockers

- user-owned inputs still pending:
- acceptance impact:

## 8. Next question (at most one)

## 8b. Scope fidelity gate

- MVP / prototype / first-version / placeholder wording present?: no | yes -> approval source:
- user-approved staging vs quality downgrade:
- verdict: preserve goal | ask downgrade decision | remove downgrade

## 9. IMPLEMENT contract

- goal:
- acceptance:
- scope fidelity / downgrade approval:
- seams / public behaviors:
- ticket frontier:
- blocking edges:
- slices:
- verification:
- route on approval: hiq-implement | hiq-debug | hiq-evolve

## 10. Sediment for CONTEXT.md

- 
