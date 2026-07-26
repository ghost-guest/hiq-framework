---
name: hiq-debug
description: >-
  HiQ 缺陷与异常修复总控。吸收原 debug / issue / fix / break-loop：负责冻结
  症状、收窄复现、CodeGraph-first 建图、单假设证伪、根因修复、回归保护、
  自测闭环，以及同类问题反复出现时的防再发沉淀。核心原则：先证明原因，
  再修改系统；修复成立，必须靠复现消失与保护路径仍绿的证据证明。
---

# hiq-debug — 症状冻结 · 根因定位 · 修复闭环 · 防再发

## Owns

- Symptom freezing and reproducibility narrowing
- CodeGraph-first root-cause mapping
- Hypothesis loop and evidence capture
- Smallest root-cause fix
- Regression guard for already-correct paths
- Self-test loop until pass or explicit block
- Repeated-bug prevention routing and lessons

## Modes

- `diagnose` — root cause still unclear; gather evidence and falsify hypotheses
- `fix` — root cause is known enough to patch directly under the same debug lane
- `regress` — a recent change likely broke a previously-correct path
- `break-loop` — same bug class or failed-fix pattern keeps returning
- `handoff` — another chat/agent must continue the debug state safely

## First principle

```text
Do not patch what you have not explained.
A fix is not done when the symptom disappears once.
A fix is done when the repro is gone, the protected good paths still pass,
and the root cause story fits the evidence.
```

## Trigger signals

Use `hiq-debug` when any of these are true:

- The user reports a bug, regression, flaky failure, or unexplained runtime behavior
- Tests fail but the real cause is not yet known
- A previous fix attempt did not hold or caused adjacent breakage
- The right next change depends on root-cause proof, not more planning
- A repeated bug class needs prevention notes, not only another patch

## Spec

```text
STATE classify:
  detect mode from the failing surface:
    cause unknown -> diagnose
    cause mostly known and patch-ready -> fix
    known recent break on previously-good path -> regress
    same bug class or repeated failed fixes -> break-loop
    context/session switch during debug -> handoff
  create or refresh `.hiq/changes/<id>/debug.md`
  if no active change exists yet:
    create one before evidence starts drifting

STATE freeze_surface:
  write the smallest truthful bug statement:
    symptom
    trigger
    impact
    expected vs actual
    owner of the failing signal
  capture the narrowest available repro command or steps
  if repro is not yet stable:
    name what is flaky, blocked, or environment-dependent
  name the nearest known-good path before changing code

STATE map_with_codegraph:
  use codegraph first on the suspected area:
    suspect symbols
    owning files/modules
    callers/callees
    impact radius
    adjacent correct paths worth protecting
  if codegraph is stale or missing:
    mark it explicitly in debug.md and fall back carefully
  do not touch shared symbols blindly without mapping blast radius

STATE evidence_gather:
  collect only evidence that can change the hypothesis ranking:
    logs
    traces
    failing tests
    recent diffs
    runtime/config facts
  summarize large logs into files/notes, not chat dumps
  record decisive evidence in debug.md
  separate facts from guesses

STATE hypothesis_loop:
  keep one active hypothesis at a time when possible
  for each hypothesis record:
    layer
    statement
    cheap falsification step
    result
    status
  reject shotgun debugging
  if a hypothesis fails, record why and move to the next best one

STATE root_cause:
  once evidence converges, name explicitly:
    where bad state starts
    why the system accepted it
    blast radius
    protected good paths
    whether the failure is local, contract, state, env, data, or operator induced
  if the story does not explain the evidence end-to-end:
    stay in diagnose mode

STATE fix_route:
  choose the truthful repair owner:
    small root-cause fix within current debug lane -> continue hiq-debug
    broader planned implementation work -> route hiq-implement with debug evidence
    interface / scope uncertainty -> route hiq-grill
  keep the fix smallest and at the cause, not the symptom shell

STATE regression_guard:
  before claiming success, name what already worked and must still work:
    nearest good path
    adjacent contracts/invariants
    smoke set for blast radius
  if no regression proof exists where blast radius implies risk:
    debug is not done

STATE self_test_loop:
  run, in order:
    original repro
    targeted regression lock
    nearest protected good path
    any fresh failing command that justified the work
  if a check fails:
    append the attempt to debug.md
    gather new decisive evidence
    continue the loop
  if all required checks pass:
    mark status passed and route to hiq-review

STATE break_loop:
  if the same class keeps recurring or multiple failed fixes happened:
    record failed hypotheses, why they were tempting, and what would catch this earlier
    route durable lesson capture to hiq-knowledge when the insight is reusable

STATE handoff:
  if context is unsafe or another session must continue:
    summarize current repro, active hypothesis, root-cause status, fix status, open blockers
    point to debug.md, evidence, and latest checkpoint
    route with exact next skill recommendation
```

## I/O

| Artifact | Path | Role |
|----------|------|------|
| Debug contract | `.hiq/changes/<id>/debug.md` | symptom, repro, hypotheses, root cause, self-test loop |
| Execution notes | `.hiq/changes/<id>/notes.md` | supporting local observations |
| Evidence | `.hiq/changes/<id>/evidence.md` | failing/passing proof for the current revision |
| Session pointer | `.hiq/session.md` | active change, next skill, latest checkpoint |
| Output | root-cause statement, fix or route, regression proof, next-skill handoff |

Template: `plugins/hiq/references/templates/debug.md`

## Required debug truths

`debug.md` must preserve these fields in recoverable form:

- symptom and trigger
- narrowest repro or blocked reason
- codegraph status and anchors
- current evidence
- active and closed hypotheses
- root-cause statement or current best suspect
- protected good paths
- verification commands
- self-test attempts and latest result
- next_skill and next_action

## Repair rules

1. Fix the cause, not only the visible symptom
2. Prefer the smallest root-cause patch that preserves the accepted design
3. Protect existing correct behavior before expanding scope
4. If the patch turns into feature/plan work, hand off honestly to `hiq-implement`
5. If the cause story weakens, go back to evidence instead of defending the patch

## Announce

```text
debug: <change-id>
mode: diagnose|fix|regress|break-loop|handoff
repro: stable|flaky|blocked
root_cause: known|suspected|unknown
protected_path: <one line>
next: hiq-debug | hiq-implement | hiq-review | hiq-grill | hiq-knowledge
```

## Gates

- No cause-unknown shotgun fixes
- No “seems fixed” claim without rerunning the repro
- No PASS while protected good paths are untested
- No giant raw log dumps in chat or debug.md
- If evidence and theory disagree, evidence wins
- Repeated bug classes must leave prevention notes, not only code changes

## Anti-patterns

1. Patch the symptom because the root cause feels obvious
2. Run five speculative fixes before one decisive check
3. Treat a flaky one-off green run as proof
4. Forget to name the path that already worked before touching shared code
5. Keep debugging in chat while debug.md stays stale
6. Turn a plan problem into endless debugging instead of routing back to the right owner

## Done

The root cause story matches the evidence, the original repro and protected good paths are verified on the current revision, and the next owner skill is explicit.