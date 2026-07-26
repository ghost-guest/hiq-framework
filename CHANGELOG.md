# Changelog

## 0.8.21 — 2026-07-26

- makes `hiq-auto` project entry and owner selection auditable from local state instead of chat inference
  - adds `entrySkill` / `entryMode` / `autoStatus` / `autoOwnerSkill` / `autoReason` / `manualOverride` markers to the project state templates
  - teaches `init-project` on POSIX and Windows to seed those markers in fresh `.hiq/session.md` and `.hiq/current-change.json`
  - expands `hiq-status` on POSIX and Windows so operators can directly inspect whether a session entered through `hiq-auto` and which owner it selected
  - updates `hiq-auto` and `hiq-session` contracts so future sessions must preserve the same audit trail
  - upgrades smoke checks to prove the markers are present and readable after initialization

## 0.8.20 — 2026-07-26

- tightens HiQ runtime truth so framework health is proven instead of inferred
  - fixes `hiq-doctor` on POSIX and Windows so a repo without `.codegraph/` now reports `overall=partial` instead of a false green
  - fixes the Windows `project-init` fallback so portable MCP wiring no longer degrades to bare PATH `codegraph` assumptions when Python is unavailable
  - adds Windows PowerShell MCP fallback wiring and platform-aware Codex MCP config generation
  - adds runnable smoke entrypoints: `hiq-smoke.sh`, `hiq-smoke.cmd`, `hiq-smoke.ps1`, plus `hiq-run ... smoke`
  - adds GitHub Actions smoke coverage for Ubuntu and Windows through `.github/workflows/hiq-smoke.yml`
  - updates the cross-platform smoke contract so CodeGraph absence is explicitly treated as incomplete initialization, not healthy state

## 0.8.19 — 2026-07-26

- folds the useful `mattpocock/skills` engineering flow into HiQ without expanding the public skill surface
  - `hiq-grill` now explicitly owns spec synthesis from known truth, seam-first planning, and ticket-frontier design
  - `hiq-implement` now explicitly owns frontier-only slice execution, public-behavior TDD, and the wide-refactor exception rule
  - `hiq-auto` now routes back to planning when a goal still lacks approved spec / seam / ticket-frontier truth
  - refreshes `grill.md`, `IMPLEMENT.md`, and `change-proposal.md` so the absorbed planning/execution contract is durable in local state

## 0.8.18 — 2026-07-26

- adds a formal **cross-platform smoke matrix** for HiQ releases and framework changes
  - introduces `plugins/hiq/references/cross-platform-smoke.md`
  - defines the minimum macOS / Linux / Windows validation surface for init, install sync, dispatcher, status, and doctor
  - makes release-time portability reporting explicit instead of implied

## 0.8.17 — 2026-07-26

- adds `hiq-auto` as an **optional auto-goal orchestration wrapper**
  - keeps the retained owner surface at 11 while adding a project-level automatic entrypoint
  - adds `AGENTS.md`, auto-mode config, and `.hiq/goals/` goal-record workflow so new conversations can enter the goal loop by default
  - expands the goal model with owner transition, acceptance, and evidence ledgers
  - adds Windows-native script surfaces for `init-project`, `install-skills`, `hiq-status`, and `hiq-doctor`
  - teaches templates/docs/routing that `hiq-auto` keeps choosing truthful owner steps until `hiq-review` proves acceptance or a real blocker is recorded
  - syncs README / FRAMEWORK / catalog / routing / bootstrap/config/init surfaces with the wrapper model

## 0.8.16 — 2026-07-26

- HiQ now absorbs the useful Comet runtime surface without introducing a second framework
  - adds `.hiq/config.yaml`, `.hiq/current-change.json`, and `.hiq/eval/` as first-class runtime/eval state
  - adds managed `hiq-status` and `hiq-doctor` scripts plus dispatcher wiring
  - upgrades `hiq-session`, `hiq-init`, `hiq-review`, `hiq-install`, and `hiq-skill` so status/probe/doctor/eval/compose/bundle/publish are owned inside the retained 11
  - syncs README / FRAMEWORK / catalog / routing / replacement map with the absorbed surface

## 0.8.15 — 2026-07-26

- `hiq-knowledge` upgraded into a **durable memory orchestrator**
  - adds clearer trigger, source-collection, distillation, connect, and handoff contracts
  - sharpens when knowledge should update `BOOTSTRAP.md` / `MEMORY.md` / `CONTEXT.md` instead of living only in a leaf artifact
  - makes future-reader surfaces part of done, not an optional afterthought

## 0.8.14 — 2026-07-26

- `hiq-evolve` upgraded into a **baseline/rollout evolution orchestrator**
  - adds explicit baseline, risk-model, execution-contract, proof-expectation, and handoff states
  - makes rollout / rollback / containment truth first-class across refactor, migrate, perf, harden, retire, and goal work
  - aligns the lane with the deeper retained-skill contract band reached by the other upgraded owners

## 0.8.13 — 2026-07-26

- `hiq-review` upgraded into a **proof and release orchestrator**
  - expands from a sharpened acceptance gate into `review` / `fix-loop` / `verify` / `demo` / `closeout` / `handoff` modes
  - adds `templates/review.md` and makes acceptance matrix, severity findings, demo proof, and verdict handoff explicit
  - aligns catalog/framework surfaces so proof/release state no longer lives only in `evidence.md` or chat

## 0.8.12 — 2026-07-26

- `hiq-grill` upgraded into a **planning and contract orchestrator**
  - expands from a thin planning stub into `triage` / `research` / `grill` / `refresh` / `handoff` modes
  - adds `templates/grill.md` and makes question budget, expert board, Proceed/Research/Defer, and approved-contract flow explicit
  - aligns framework/catalog surfaces so `grill.md` + `IMPLEMENT.md` become the real pre-code planning state

## 0.8.11 — 2026-07-26

- `hiq-install` upgraded into a **host/runtime install orchestrator**
  - expands from a thin install checklist into `preview` / `apply` / `repair` / `sync` / `verify` modes
  - makes target detection, backup truth, host/runtime sync, bundled codegraph health, and blocked-write honesty explicit
  - adds `templates/install.md` and aligns install docs/routing with retained 11-skill host ownership

## 0.8.10 — 2026-07-26

- `hiq-implement` upgraded into an **execution orchestrator**
  - expands from a thin execution checklist into `execute` / `tdd` / `isolate` / `delegate` / `handoff` modes
  - makes approved `IMPLEMENT.md`, spec loading, one-slice execution, CodeGraph-first preflight, and fresh self-check evidence explicit
  - refreshes `templates/IMPLEMENT.md` and top-level routing/docs so absorbed execution capabilities no longer point at removed thin skills

## 0.8.9 — 2026-07-26

- `hiq-debug` upgraded into a **root-cause repair orchestrator**
  - expands from a thin checklist into `diagnose` / `fix` / `regress` / `break-loop` / `handoff` modes
  - enforces symptom freeze, CodeGraph-first mapping, single-hypothesis loop, regression guard, and self-test loop
  - refreshes `templates/debug.md` to remove stale pre-11-skill routes and preserve compact handoff truth

## 0.8.8 — 2026-07-26

- `hiq-session` upgraded into a **session continuity orchestrator**
  - sharpens start / resume / continue / finish / handoff / profile contracts
  - enforces local trust order and checkpoint-before-switch discipline
  - makes `session.md` a strict compact-safe resume packet rather than a loose note file

## 0.8.7 — 2026-07-25

- `hiq-init` upgraded into a **project baseline orchestrator**
  - expands from thin init stub into baseline files + managed CodeGraph + portable MCP + legacy absorb
  - requires new-agent continuation from `.hiq/BOOTSTRAP.md` / `MEMORY.md` / `session.md`
  - makes managed binary installation and `.codegraph/` creation part of init success

## 0.8.6 — 2026-07-25

- `hiq` upgraded into a **real root dispatcher**
  - expands from thin route list into tiering + lane selection + ambiguity gate + single-primary-skill handoff
  - upgrades `routing-table.md` with tie-break rules and honest-owner routing
  - makes “smallest truthful next skill” the core routing principle

## 0.8.5 — 2026-07-25

- `hiq-skill` upgraded into a **framework governance orchestrator**
  - expands from thin `build/upgrade` stub into `upgrade` + `absorb` + `build` + `sync`
  - adds `skill-change.md` template for problem, owner, overlap analysis, affected files, rollback, and sync tracking
  - makes “strengthen existing retained skill first” the default before any new-skill proposal

## 0.8.4 — 2026-07-24

- `hiq-knowledge` upgraded into a **durable knowledge orchestrator**
  - expands from thin `adr/keep/audit` stub into `adr` + `lesson` + `casebook` + `audit`
  - adds explicit capture rules for high-value cases where a fix only succeeded after multiple failed attempts
  - adds `lesson.md` and `casebook.md` templates for reusable rules, failed hypotheses, decisive evidence, and regression guards

## 0.8.3 — 2026-07-24

- `hiq-evolve` upgraded into a real evolution orchestrator
  - mode contracts for refactor / migrate / perf / harden / retire / goal
  - adds `evolve.md` template for baseline, success metric, must-not-regress, rollback
  - routes unclear work back to hiq-grill and execution to hiq-implement / hiq-review

## 0.8.2 — 2026-07-24

- `hiq-review` sharpened into a **real acceptance gate**
  - PASS now explicitly depends on fresh evidence for each Acceptance item
  - model confidence / code-looking-right is explicitly rejected as proof
  - user-facing changes require realistic path evidence, not unit tests alone

## 0.8.1 — 2026-07-24

- `hiq-session` upgraded for **new-session resume** and **compact-safe continuity**
  - local resume packet lives in `.hiq/session.md`
  - recovery order formalized: BOOTSTRAP → MEMORY → session → active change → checkpoint → graph/codegraph
  - checkpoint path must be stored in session before session switch under context pressure
  - new session should continue from local files, not prior chat history

## 0.8.0 — 2026-07-24

- **Framework compressed to 11 retained skills**
  - retained: `hiq`, `hiq-init`, `hiq-install`, `hiq-session`, `hiq-grill`, `hiq-implement`, `hiq-debug`, `hiq-review`, `hiq-evolve`, `hiq-knowledge`, `hiq-skill`
  - removed dozens of thin user-facing skills; capabilities absorbed as modes/lenses/phases
  - README / FRAMEWORK / SKILL_CATALOG / routing / replacement map rewritten for 11-skill edition


## 0.7.8 — 2026-07-24

- `hiq-check` upgraded into an **acceptance-first final gate**
  - opens `IMPLEMENT.md` as the primary contract, not just lint/test output
  - PASS now requires explicit coverage of each Acceptance item and slice done-when
  - user-facing paths, regression guard, and scope drift are part of the decision

## 0.7.7 — 2026-07-24

- `hiq-implement` upgraded into a real execution skill
  - requires approved `IMPLEMENT.md` as coding contract
  - slice-by-slice implementation with local self-check before checkbox completion
  - codegraph-first context for shared symbols / impact / module ownership
  - this was the pre-11-skill version and still referenced now-removed thin routes later absorbed into retained lanes

## 0.7.6 — 2026-07-24

- `hiq-debug` is now **CodeGraph-first**
  - assumes hiq-init integrated codegraph-rs and starts with symbol/context/callers/callees/impact/files
  - debug template now records module graph, callers, impact surface
  - regression guard uses graph-adjacent paths to avoid breaking currently-correct behavior

## 0.7.5 — 2026-07-24

- `hiq-debug` upgraded with **regression guard + self-test loop**
  - before fix: name existing correct behavior that must not regress
  - after fix: self-check + self-test must pass before claiming success
  - on failure: capture more evidence/logs and continue repair loop until pass or explicit block
  - template `templates/debug.md` now includes Regression guard and Self-test loop

## 0.7.4 — 2026-07-24

- Corrected merge direction: **`hiq-decision` + `hiq-clarify` fully folded into `hiq-grill`**
  - `hiq-grill` now owns decision gate + five-bullet alignment + brainstorm + plan
  - removed standalone `hiq-clarify`
  - updated routing/catalog/README/framework/feature/session/perf/tdd references


## 0.7.3 — 2026-07-22

- **`hiq-grill` multi-expert council** (PM/ARCH/FE/BE/PERF/SEC/QA/OPS/DX/DATA)
  - experts for internal analysis + IMPLEMENT quality, not multi-question spam
  - `references/grill-experts.md` roster, activation matrix, question format
  - grill log Expert board; IMPLEMENT § Expert review
  - still: budget + 1 decision/turn + fact-local-verify

## 0.7.2 — 2026-07-22

- **Removed** `hiq-plan` and `hiq-brainstorm` — fully folded into `hiq-grill`
  - modes: `triage` | `grill` | `refresh`
  - catalog/routing/feature/decision/continue/tdd/README updated

## 0.7.1 — 2026-07-22

- `hiq-review` absorbed the verify/check/closeout acceptance lane
- `hiq-session` became the continuity hub for resume/finish/handoff
- `hiq-evolve` became the single evolution lane
- `hiq-knowledge` became the durable capture lane

## 0.7.0 — 2026-07-22

- First consolidated HiQ framework cut
