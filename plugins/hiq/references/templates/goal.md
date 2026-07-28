# Goal — <title>

- **goal_id**: `<id>`
- **entry_skill**: `hiq-auto`
- **status**: active | blocked | accepted | handoff
- **mode**: auto | goal | continue | override | handoff
- **current_owner**: `hiq-...`
- **next_owner**: `hiq-...`
- **active_change**: `.hiq/changes/<id>/` or none
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

| time | owner | evidence | freshness | impact |
|------|-------|----------|-----------|--------|
| | `hiq-...` | command / demo / eval / review finding | fresh | |

## 7. User decisions

| id | question | why user-owned | status | answer |
|----|----------|----------------|--------|--------|
| D1 | | | open | |

## 8. Handoff / checkpoint

- latest_checkpoint:
- resume command: `继续 <checkpoint path>` or `$hiq-auto`

## 9. Final verdict

- accepted?: no | yes
- review source:
- follow-up work:
