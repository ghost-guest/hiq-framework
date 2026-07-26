# Debug — <title>

- **change**: `.hiq/changes/<id>/`
- **tier**: L0 | L1 | L2 | L3
- **status**: open | diagnosing | root-caused | fixing | self-testing | passed | handed-off | blocked
- **mode**: diagnose | fix | regress | break-loop | handoff
- **symptom_owner**: user | test | runtime | CI | operator
- **repro_status**: stable | flaky | blocked
- **fix_attempts**: 0
- **next_skill**: hiq-debug | hiq-implement | hiq-review | hiq-grill | hiq-knowledge | hiq-session

## 1. Symptom

- user-visible or system-visible issue:
- trigger:
- impact:
- expected vs actual:
- first failing signal:

## 2. Reproduction

```bash
# narrowest repro command or check
```

- environment / data / flags:
- if flaky, what varies:
- if blocked, why:
- nearest known-good path:

## 3. CodeGraph map

- codegraph status: healthy | stale | missing
- suspect symbols:
- owning modules / files:
- callers / reachability:
- impact surface:
- protected adjacent good paths:

## 4. Current evidence

- logs / traces / screenshots:
- recent diffs / suspects:
- config / data / environment facts:
- decisive fact so far:

## 5. Hypothesis loop

| id | layer | hypothesis | experiment / check | result | status |
|----|-------|------------|--------------------|--------|--------|
| H1 | local / module / contract / state / env / data / operator | | | | open / confirmed / refuted |

## 6. Root cause

- bad state starts at:
- why existing checks allowed it:
- blast radius:
- contributing factors:
- confidence: low | medium | high

## 7. Regression guard (existing correct behavior)

- behavior that already works and must stay correct:
- nearest good path:
- contracts / invariants not allowed to drift:
- minimal smoke set after fix:

## 8. Fix track

- proposed fix:
- smallest root-cause patch point:
- verification path:
- if routing away, why:
- route: hiq-debug self-fix | hiq-implement | hiq-grill | hiq-review | hiq-knowledge

## 9. Self-test loop

| attempt | change | self-checks run | result | next action |
|---------|--------|-----------------|--------|-------------|
| 1 | | repro + regression + protected path | pass / fail | |

## 10. Handoff / checkpoint

- latest checkpoint:
- blocker if not done:
- next_skill:
- next_action:

## 11. Residual risk

- 
