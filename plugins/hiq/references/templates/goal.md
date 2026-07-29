# Goal — <title>

- **goal_id**: `<id>`
- **state_revision**: 1
- **content_revision**: 0
- **entry_skill**: `hiq-auto`
- **status**: active | blocked | accepted | handoff
- **mode**: auto | goal | continue | override | handoff
- **current_owner**: `hiq-...`
- **next_owner**: `hiq-...`
- **active_change**: `.hiq/changes/<id>/` or none
- **review_status**: not-run | pending | pass | partial | fail | blocked
- **review_path**: `.hiq/changes/<id>/review.md` or none
- **reviewed_content_revision**: none | number
- **updated**:

## 1. Requested outcome

- user request:
- accepted complete result:
- staged delivery approved?: no | yes -> boundary:
- scope downgrade approved?: no | yes -> exact approval source:

## 2. Goal statement

- goal_now:
- non-goals:
- acceptance target:
- anti-downgrade rule: MVP / prototype / first-version / placeholder requires explicit user approval

## 3. Current truthful bottleneck

- why this owner is current:
- owner lease action:
- owner lease started:
- evidence gap:
- explicit blocker if any:
- user-owned inputs still pending:
- acceptance item still open:

## 4. Owner transition ledger

| step | owner | mode | trigger | reason | result | next |
|------|-------|------|---------|--------|--------|------|
| 1 | `hiq-...` | | | | | |

## 5. Acceptance ledger

| item | required proof | current status | source |
|------|----------------|----------------|--------|
| A1 | | open | |

## 6. Evidence ledger

| time | content revision | owner | evidence | freshness | impact |
|------|------------------|-------|----------|-----------|--------|
| | 0 | `hiq-...` | command / demo / eval / review finding | fresh | |

## 7. User decisions

| id | question | why user-owned | status | answer |
|----|----------|----------------|--------|--------|
| D1 | | | open | |

## 8. Handoff / checkpoint

- checkpoint_required: no | yes
- checkpoint_reason: none | handoff | compaction | context-pressure
- latest_checkpoint:
- resume command: `继续 <checkpoint path>` or `$hiq-auto`

## 9. Final verdict

- accepted?: no | yes
- review verdict: PENDING | PASS | PARTIAL | FAIL | BLOCKED
- review source:
- reviewed content revision:
- follow-up work:
