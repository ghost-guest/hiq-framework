# hiq-grill playbook (deep ref)

Absorbed from: do-it-grill, trellis-brainstorm/planning, Aegis baseline+evidence,
ExpertTeam-style domain lenses, anti–grill-me verbosity.

Also load: `grill-experts.md` (multi-expert council).

## Question budget (hard)

| Tier | Max user **decision** questions (whole grill) | Per turn |
|------|-----------------------------------------------|----------|
| L0 | 0 (prefer zero); hard max 1 | 1 |
| L1 | 1 | 1 |
| L2 | 3 | 1 |
| L3 | 5 | 1 |

Never spend budget on:

- facts the repo can answer
- process ("要不要我先搜代码？") — just search
- multi-choice laundry lists of 5+ open questions
- re-asking after already decided
- **one question per expert** (forbidden)

## fact vs decision

| kind | who resolves | action |
|------|--------------|--------|
| fact | agent + repo | verify (codegraph/Read/test); log evidence |
| engineering choice | experts + chair | recommend in IMPLEMENT; do not ask unless product-owned |
| decision | user | one question + multi-expert recommendation + trade-off |

## Highest-leverage premise

Ask (or verify) the premise that, if wrong, **invalidates the most downstream work**. Prefer scope/acceptance/compatibility over micro-naming.

## Expert council (default for L1+ grill/refresh)

1. **Activate** relevant experts only (`grill-experts.md` matrix).  
2. **Silent round**: each expert ≤3 bullets (support / veto / needs user?).  
3. **Chair merge**: facts → verify; engineering → recommend; product trade-offs → rank by leverage.  
4. **User channel**: at most one decision question, tagged with expert interest.  
5. **IMPLEMENT**: write Expert review (consensus + dissent).

Experts improve **quality of thinking and docs**, not **quantity of questions**.

## Lenses (orthogonal checks; silent)

1. Truth — verified vs assumed  
2. Scope — smallest complete outcome  
3. Acceptance — exact evidence of done  
4. Interface — contract another module relies on  
5. Failure — most likely ship-a-bug path  
6. Review — what a skeptic blocks  
7. Maintenance — avoid future churn without scope creep  
8. Baseline (Aegis) — goal, owner, patterns, verify path known  

## First principles (Trellis, when vague)

1. Restate problem in one sentence without solution words  
2. List fundamental truths (not conventions)  
3. Rebuild minimal solution upward  
4. Cut anything not serving acceptance  

## Options matrix (when ≥2 real approaches)

| approach | PM | ARCH | FE/BE | PERF | risk | recommend? |
|----------|----|------|-------|------|------|------------|
| A | | | | | | |
| B | | | | | | |

Pick one recommendation; only ask user if trade-off is product-owned.

## Rationalizations (force another loop)

- "feels reasonable" → need evidence  
- "user said it works that way" → treat as premise, verify  
- "fix in review" → grill now if cheap  
- "both work" → pick one for this change  
- "each expert needs a turn with the user" → **no**; merge offline  

## Final gate

User must **explicitly approve** `IMPLEMENT.md` (or latest summary) before product code edits.  
Initial "去做吧" before the plan exists ≠ approval of the plan.
