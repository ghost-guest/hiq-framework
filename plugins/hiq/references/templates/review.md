# Review — <title>

- **change**: `.hiq/changes/<id>/`
- **mode**: review | fix-loop | verify | demo | closeout | handoff
- **status**: open | blocked | partial | pass | fail
- **updated**:

## 1. Review scope

- goal / change summary:
- diff / files under review:
- approved contract:
- reviewer focus:

## 2. Acceptance matrix

| id | acceptance item | proof source | status | notes |
|----|-----------------|--------------|--------|-------|
| A1 | | command / demo / file | pending \| pass \| fail | |

## 3. Findings

| severity | location | problem | fix hint | status |
|----------|----------|---------|----------|--------|
| Blocking | path:line | | | open \| fixed \| accepted-risk |

## 4. Evidence checks

| check | why it matters | latest proof | status |
|------|----------------|--------------|--------|
| original acceptance path | | | pending \| pass \| fail |

## 5. Eval / benchmark evidence

- eval required?: yes | no
- config: `.hiq/eval/eval.yaml`
- run/report:
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

- verdict: PASS | PARTIAL | FAIL
- merge / release recommendation:
- next route: hiq-review | hiq-implement | hiq-debug | hiq-grill | hiq-session

## 9. Closeout notes

- 
