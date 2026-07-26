# HiQ Iron Laws

1. **Sole framework**  
   All workflow state lives under `.hiq/`. Do not run parallel Trellis/do-it/Assay task systems. Legacy dirs are absorb inputs only.

2. **Baseline-first**  
   Before L2+ edits: goal, owner, patterns, contracts, verification path.

3. **Evidence-before-done**  
   Done/fixed/passing needs fresh command output summarized in `evidence.md`.

4. **Tier before ceremony**  
   Classify L0–L3 (or Goal). L0 must not grow design/ADR/multi-agent ritual.

5. **Failure-mode forecast (L2+)**  
   Name likely classes: live-path gap, state-machine gap, contract drift, synthetic proof, operator gap, evidence drift — or explicitly none.

6. **Proof path (L2+ behavior work)**  
   `producer → contract → transport → state → surface → verification`

7. **Grill: verify facts, ask decisions**  
   Cheap local truth is not a user question. Ask at most one load-bearing decision at a time. Sediment terms into CONTEXT.md.

8. **Spec before code (L2+)**  
   Load `.hiq/spec/` via `hiq-spec` before implementation.

9. **Fix-loop honesty**  
   Blocking/Important review findings must be cleared and re-reviewed; no “addressed” without re-check.

10. **Human-in-the-loop on irreversible edges**  
    Migration cutover, public break, secrets, prod deploy, mass delete → confirm.

11. **One change, one outcome**  
    Don’t bundle feature+refactor+migrate unless user orders Heavy with rollback.

12. **Retirement track**  
    New compat/fallback records remove-by condition.

13. **Context hygiene**  
    Large logs/tool dumps → workspace files; chat keeps summaries.

14. **Spec over prose in skills**  
    Routing truth is `## Spec` state machines.

15. **User message wins**  
    Explicit user instructions outrank defaults for product behavior.
