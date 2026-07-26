# hiq-grill Expert Council

Multi-expert mode for **thinking and authoring**, not for multi-channel interrogation.

## Principle

```text
Experts argue in private → one chair merges → user hears ONE decision question
                                       → IMPLEMENT carries expert notes + dissent
```

- **Never** ask one question per expert (that is grill-me).
- **Never** role-play long monologues at the user each turn.
- Experts are **checklists + judgment prompts**, not separate agents unless L3 explicitly delegates.

## Roster (activate by relevance)

| ID | Role | Primary concerns | Mute when |
|----|------|------------------|-----------|
| PM | 产品经理 | job-to-be-done, scope, acceptance, priority, non-goals, user value | pure refactor/infra with no UX |
| ARCH | 架构师 | boundaries, coupling, data flow, failure domains, evolution | single-file L0 |
| FE | 前端 | UX states, a11y, perf perceived, API contract from UI, empty/error/loading | no UI surface |
| BE | 后端 | API/schema, authz, idempotency, validation, persistence, jobs | pure CSS/copy |
| DATA | 数据 | migrations, consistency, indexes, PII, backfill | no data change |
| PERF | 性能 | hot path, complexity, caching, N+1, budgets, measurement | no latency/cost concern |
| SEC | 安全 | trust boundary, injection, secrets, authn/z, supply chain | no new surface/trust |
| QA | 质量 | repro, regression tests, proof path, edge cases | — usually always light |
| OPS | 运维/SRE | deploy, rollback, flags, observability, on-call | no ship/ops impact |
| DX | 平台/DX | CLI/API ergonomics, docs, skill/agent path | user-facing product only |

Default **core board** for L2 product work: `PM + ARCH + BE|FE (by stack) + QA + PERF(if user-facing or data-heavy)`.  
L0: skip board; L1: PM + implementer domain only; L3: full relevant board + optional bounded delegation plan under `hiq-implement`.

## Silent review prompts (internal)

Each active expert answers in ≤3 bullets **to the chair** (agent), not to the user:

1. **Support** — what must be true for this plan to work?  
2. **Blocker** — what would make you veto ship?  
3. **Decision** — is there a user-owned choice here? (yes/no + one-line)

Chair merges:

- facts → verify locally  
- expert-only engineering choices → **recommend, do not ask**  
- product/scope/risk trade-offs → **one** user question, labeled with which experts care  

## Question format (expert-aware, still one Q)

```markdown
**【待决 · <PM|ARCH|…> 共同关注】** <one decision>

- 为何卡住计划：…
- 专家倾向：…（PM: … / ARCH: …）
- 推荐：**<option>** — 因为 …
- 若选另一边：代价 …
```

Do not list five experts' separate questions.

## Synthesize → IMPLEMENT

In `design.md` / `IMPLEMENT.md` add short **Expert review**:

```markdown
## Expert review
- Active: PM, ARCH, BE, QA
- Consensus: …
- Dissent: PERF warns … (mitigation: …)
- Deferred: SEC full audit → follow-up harden
```

## Activation matrix (quick)

| Work shape | Active |
|------------|--------|
| New user feature (full stack) | PM ARCH FE BE QA PERF |
| API-only | PM ARCH BE QA SEC |
| UI-only | PM FE QA PERF |
| Migration | ARCH BE DATA OPS QA |
| Perf goal | PERF BE|FE ARCH QA |
| Security harden | SEC BE ARCH OPS |
| Skill/framework (this repo) | PM DX ARCH QA |

## Anti-patterns

1. "Roundtable transcript" of 800 tokens every turn  
2. Six questions "from six experts"  
3. Activating all 10 experts on L0 typo fix  
4. Using experts to avoid reading the codebase  
