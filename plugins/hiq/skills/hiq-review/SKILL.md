---
name: hiq-review
description: >-
  HiQ 交付前 proof / release 总控。吸收原 review / fix-loop / verify / check /
  demo / closeout，并内化 Comet 风格的 eval ingest：负责围绕批准契约建立 acceptance
  matrix、输出带严重级别的 findings、逼所有“已完成”声明拿出当前修订的新鲜证据，并在需要时
  接入 `.hiq/eval/` 的基准/评估结果，直到可放行或诚实失败。核心原则：完成不是感觉、不是绿
  测试截图，而是这次变更真的证明了目标结果。
---

# hiq-review — 审查 · 证据 · Eval · 验收 · 放行

## Owns

- Review scope definition against the approved contract
- Acceptance matrix and proof-source mapping
- Severity-ranked findings
- Fix-loop until required severities clear
- Fresh evidence gate for user-visible and system-visible outcomes
- Eval/benchmark ingest when local review benefits from structured scoring
- Release / closeout recommendation with honest next route
- Handoff when proof work must continue in another session

## Modes

- `review` — inspect the current diff and contract for findings and missing proof
- `fix-loop` — re-run the same review scope after required fixes
- `verify` — focus on proof gaps when implementation is mostly done but not yet proven
- `demo` — validate user-path or operator-path outcomes that need realistic walkthrough evidence
- `eval` — ingest or run structured local evaluation artifacts and translate them into review truth
- `closeout` — prepare the final release or merge recommendation
- `handoff` — pause or switch sessions without losing the review state

## First principle

```text
Belief is not evidence.
Green-looking code is not acceptance.
A passing command or eval score only matters when it proves the required outcome for this revision.
A scaffold, MVP, fixture, or placeholder result is blocked when the requested outcome still depends on real user-owned inputs.
```

## Trigger signals

Use `hiq-review` when one or more are true:

- Implementation or repair is materially done and the honest question is pass/fail
- Someone claims the work is finished, fixed, passing, or ready to ship
- The change needs findings, acceptance proof, demo proof, structured eval proof, or closeout judgment
- The next step is deciding whether remaining gaps belong to implementation, debug, or more proof

Do not use `hiq-review` when the plan itself is still unclear; route to `hiq-grill`.
Do not stay here when the main problem is missing implementation work; route to `hiq-implement`.
Do not pretend proof can replace root-cause work when the actual failure reason is still unknown; route to `hiq-debug`.

## Spec

```text
STATE classify:
  determine mode from the real bottleneck:
    first review pass on a materially done change -> review
    required findings were fixed and need re-check -> fix-loop
    implementation mostly exists but proof is weak -> verify
    user/operator path still needs realistic walkthrough evidence -> demo
    structured local evaluation should inform the verdict -> eval
    release note / merge recommendation is the active task -> closeout
    session/context switch during proof work -> handoff
  create or refresh `.hiq/changes/<id>/review.md`

STATE load_scope:
  read in order:
    IMPLEMENT.md
    tasks.md
    evidence.md
    notes.md
    debug.md when the work came from hiq-debug
    relevant diff / changed files
    `.hiq/eval/eval.yaml` when present
    relevant `.hiq/eval/runs/<...>` report if eval is in play
  define explicit review scope:
    goal
    changed surfaces
    non-goals
    promised acceptance items
    blast radius worth protecting
  if approved contract is missing or stale:
    route to hiq-grill before judging readiness
  if contract or artifacts use MVP / prototype / first-version / placeholder / later-scope language without explicit approval:
    route to hiq-grill for scope fidelity before judging readiness
  if real API data, workbooks, credentials, environments, screenshots, or other user-owned inputs are required for acceptance and still missing:
    verdict is blocked or partial, not pass
    next route is hiq-grill when the contract must change, otherwise blocked waiting for input

STATE build_matrix:
  write the acceptance matrix in `review.md`
  for each Acceptance item capture:
    item id
    required outcome
    proof source
    latest status
    notes / gaps
  if no concrete proof source can exist yet:
    status stays pending, not pass

STATE findings_pass:
  inspect for:
    correctness
    contract drift
    unapproved scope downgrade from the requested outcome
    security / trust-boundary mistakes
    regression risk
    hidden scope expansion
    operator or demo gaps
    evaluation blind spots or weak benchmark relevance
  emit findings by severity:
    Blocking | Important | Nice
  every finding must include:
    location
    problem
    fix hint
    status

STATE fix_loop_gate:
  if Blocking or Important findings remain:
    do not issue a pass or release recommendation
    route the smallest honest next owner:
      implementation gap -> hiq-implement
      hidden cause or unstable repro -> hiq-debug
      contract drift -> hiq-grill
    after fixes, return to the same scope in fix-loop mode

STATE evidence_gate:
  for each acceptance item ask:
    where is the fresh proof?
    does it come from this revision, not stale chat or old CI memory?
    does it prove the required user-visible or system-visible result?
  if the answer to any required item is no:
    mark the item pending or fail
  green tests alone do not pass items they do not actually prove

STATE eval_gate:
  when mode=eval or eval artifacts exist:
    inspect `.hiq/eval/eval.yaml` and the chosen run/report
    ask:
      is the task set relevant to this change?
      are the rubric and acceptance target aligned?
      do scores/measures reflect this revision?
      does the report reveal failure clusters that manual review should elevate?
    treat eval as structured supporting evidence, not an override of manual truth
    if eval and direct evidence disagree:
      direct evidence wins unless the eval exposes a missing scenario that should become a finding

STATE demo_gate:
  if a user-facing, operator-facing, or workflow path changed:
    require realistic path proof:
      demo
      smoke
      manual walkthrough
      E2E-style evidence
    unit tests or eval may support the claim but do not replace path proof

STATE regression_gate:
  name the previously-correct paths that matter for this blast radius
  require fresh proof where risk warrants it
  if regression-sensitive paths are unproven:
    review cannot pass yet

STATE verdict:
  PASS only if all are true:
    Blocking = 0
    Important = 0
    every required Acceptance item has matching fresh proof
    done-when claims for completed slices are satisfied
    no material scope drift or unapproved downgrade beyond non-goals
    no acceptance-critical user-owned input is still pending
    protected good paths are proven where needed
    evidence belongs to the current revision/worktree
    eval results, when used, do not contradict the release claim
  PARTIAL if some proof exists but the release bar is not met
  BLOCKED if the remaining acceptance proof depends on user-owned external input that is not available yet
  FAIL if key acceptance proof is missing, a critical command is red, eval reveals an unaddressed required gap, or required findings remain

STATE closeout:
  append the release summary and remaining risks to review.md and evidence.md
  if eval mattered, cite the relevant run/report and what it did or did not prove
  recommend:
    merge / release
    do-not-merge yet
    continue proof only
  make the next route explicit:
    hiq-review | hiq-implement | hiq-debug | hiq-grill | hiq-session

STATE handoff:
  summarize the active scope, open findings, missing proof, eval status, verdict status, and next owner
  point to review.md, evidence.md, eval artifacts, and session/checkpoint state
```

## I/O

| Artifact | Path | Role |
|----------|------|------|
| Review state | `.hiq/changes/<id>/review.md` | acceptance matrix, findings, verdict, release notes |
| Execution contract | `.hiq/changes/<id>/IMPLEMENT.md` | approval source and acceptance promises |
| Progress state | `.hiq/changes/<id>/tasks.md` | slice completion claims under review |
| Evidence | `.hiq/changes/<id>/evidence.md` | fresh command/demo/eval summaries for this revision |
| Debug state | `.hiq/changes/<id>/debug.md` | root-cause and regression context when review follows a repair |
| Eval config | `.hiq/eval/eval.yaml` | local rubric and output contract |
| Eval runs | `.hiq/eval/runs/` | benchmark/evaluation reports when used |
| Session pointer | `.hiq/session.md`, `.hiq/current-change.json` | active change, checkpoint, next owner |
| Output | findings, acceptance verdict, release recommendation, honest next route |

Templates:

- `plugins/hiq/references/templates/review.md`
- `plugins/hiq/references/templates/eval.yaml`
- `plugins/hiq/references/templates/eval-report.md`

## Required review truths

`review.md` and `evidence.md` must preserve these in recoverable form:

- review scope and approved contract source
- scope fidelity / downgrade approval state
- pending user-owned inputs and their acceptance impact
- acceptance matrix with latest status per item
- findings with severity, location, and current status
- proof source for every release-relevant claim
- whether demo/user-path evidence was required and whether it exists
- whether eval evidence was used and what it proved
- regression-sensitive paths and their current proof state
- current verdict, remaining gaps, and next owner skill

## Review rules

1. Review the contract before reviewing confidence
2. Findings lead; release summary comes after the problems are clear
3. Re-review the same scope after fixes instead of assuming the issue is gone
4. If a proof source does not demonstrate the target outcome, treat it as missing proof
5. Partial evidence is still useful, but it does not justify a pass label
6. Eval is a force multiplier for proof, not an excuse to skip manual judgment
7. When review discovers contract drift, say so explicitly and route back to planning

## Announce

```text
review: <change-id>
mode: review|fix-loop|verify|demo|eval|closeout|handoff
scope: <one line>
findings: B=<n> I=<n> N=<n>
verdict: pass|partial|fail|blocked
next: hiq-review | hiq-implement | hiq-debug | hiq-grill | hiq-session
```

## Gates

- No PASS while any Blocking or Important finding is open
- No release recommendation without fresh acceptance proof
- No stale CI/chat memory standing in for current revision evidence
- No `eval` result treated as a substitute for missing user-path proof
- No “tests passed” shortcut when user-path proof is still missing
- No closeout summary that hides open scope drift or unresolved findings
- No PASS for MVP / prototype / first-version / placeholder work unless that downgrade was explicitly approved
- No PASS while acceptance-critical user-owned inputs are still pending
- No review state living only in chat while `review.md` is stale

## Anti-patterns

1. Give PASS because the code looks reasonable
2. Reuse yesterday's proof for today's revision
3. Let unit tests or eval scores substitute for a changed user workflow with no realistic path check
4. Fix findings and skip re-reviewing the same scope
5. Write a warm release summary before naming the real gaps
6. Keep proof work in `evidence.md` only, with no acceptance matrix or verdict record
7. Run eval on the wrong task set and treat the number as authoritative anyway
8. Review an MVP-shaped subset as done when the user asked for the complete accepted project outcome

## Done

The review scope is explicit, every release-relevant acceptance item has current proof status, required findings are cleared or honestly blocking, and the release recommendation matches the evidence instead of model belief.
