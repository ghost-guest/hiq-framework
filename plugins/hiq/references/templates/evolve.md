# Evolve — <title>

- **change**: `.hiq/changes/<id>/`
- **mode**: refactor | migrate | perf | harden | retire | goal
- **tier**: L0 | L1 | L2 | L3
- **status**: draft | approved | in-progress | done
- **approved_by_user**: no | yes (message ref)

## 1. Goal

## 2. Success metric / finish line

- 

## 3. Non-goals

- 

## 4. Must stay true

- behavior / API / UX / data invariants that cannot regress:
- protected existing paths:

## 5. Current baseline

- current behavior:
- current metric / risk / debt:
- codegraph hotspots / impact:

## 6. Mode-specific plan

### Refactor
- equivalence boundary:
- characterization tests / smoke:

### Migrate
- source → target:
- compatibility window:
- rollout steps:
- rollback steps:

### Perf
- baseline metric:
- target metric:
- measurement command:

### Harden
- threat / failure class:
- containment / observability:

### Retire
- old path to remove:
- proof it is dead / safe to remove:

### Goal
- target condition:
- measurement cadence:

## 7. Execution slices

### Slice 1
- outcome:
- touch:
- verify:
- done when:

## 8. Verification

```bash
# primary
```

```bash
# regression / secondary
```

## 9. Rollback / containment

## 10. Residual risk

- 
