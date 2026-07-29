# Review — <title>

- **change**: `.hiq/changes/<id>/`
- **change_id**: `<id>`
- **content_revision**: 0
- **reviewed_content_revision**: 0
- **mode**: review | fix-loop | verify | demo | eval | closeout | handoff
- **status**: open | blocked | partial | pass | fail
- **verdict**: PENDING | PASS | PARTIAL | FAIL | BLOCKED
- **updated**:

## 1. Review scope

- goal / change summary:
- diff / files under review:
- approved contract:
- reviewer focus:

## 2. Acceptance matrix

| id | acceptance item | proof source | status | notes |
|----|-----------------|--------------|--------|-------|
| A1 | | command / demo / file | pending | |

## 3. Findings

| severity | location | problem | fix hint | status |
|----------|----------|---------|----------|--------|
| Blocking | path:line | | | open |

## 4. Evidence checks

| check | why it matters | latest proof | status |
|------|----------------|--------------|--------|
| original acceptance path | | | pending |

## 5. Eval / benchmark evidence

- eval applicability: unknown | not-applicable | optional | required
- eval status: not-run | running | pass | fail | blocked | not-applicable
- config: `.hiq/eval/eval.yaml`
- run/report:
- reason when not applicable:
- key metrics:
- ingest into verdict?: yes | no

## 6. Demo / user-path proof

- required?: yes | no
- path:
- latest proof:
- gaps:

## 7. Scope drift / regression watch

- non-goal drift:
- protected good paths:
- regression proof:

## 8. Verdict

- verdict: PENDING | PASS | PARTIAL | FAIL | BLOCKED
- reviewed content revision:
- merge / release recommendation:
- next route: hiq-review | hiq-implement | hiq-debug | hiq-grill | hiq-session

## 9. Closeout notes

-
