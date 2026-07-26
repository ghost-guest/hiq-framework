# 被替代体系 → HiQ 11-skill 映射

HiQ 是**唯一**开发框架。旧能力不再对应 many small skills，而是吸收到 11 个厚 skill。

| 原体系能力 | HiQ 承载 |
|------------|----------|
| trellis-start / trellis-continue / trellis-finish-work | `hiq-session` |
| trellis-brainstorm / prd / do-it-grill / do-it-planning / do-it-slicing | `hiq-grill` |
| matt engineering `to-spec` / architecture-style planning synthesis | `hiq-grill` |
| trellis-before-dev / do-it-tdd / do-it-worktree / do-it-subagent-orchestration | `hiq-implement` |
| matt engineering `to-tickets` / `tdd` | `hiq-implement` |
| do-it-debugging / trellis-break-loop / issue fixing | `hiq-debug` |
| do-it-review-loop / do-it-fix-loop / do-it-verification-gate / trellis-check / T-Tools demo | `hiq-review` |
| refactor / migrate / perf / harden / retire / goal-driven evolution | `hiq-evolve` |
| architecture-copilot / do-it-architecture-scan / interface-drill / domain-language / T-Tools decision / Assay study | `hiq-grill` |
| COMPASS profile / handoff | `hiq-session` |
| ADR / knowledge / audits | `hiq-knowledge` |
| Comet status / resume-probe / dashboard snapshot | `hiq-session` |
| Comet Native runtime state / current-change / eval scaffold | `hiq-init` + `hiq-review` |
| Comet doctor / runtime repair | `hiq-install` |
| Comet-any compose / bundle / publish / skill eval governance | `hiq-skill` |
| skill build / skill upgrade | `hiq-skill` |
| trellis project bootstrap / codegraph-auto / aegis project context | `hiq-init` |
| keysmith install safety / framework dependency install | `hiq-install` |

## 移除原则

- 不再暴露 many thin skill names 给用户记忆。
- 保留 11 个厚 skill；其余能力作为 mode / lens / phase 内化。
- 外部工程工作流优先做能力吸收，不做命名照搬；例如 `to-spec` / `to-tickets` / `tdd` 已分别落到 `hiq-grill` / `hiq-implement`。
- 不再路由到 Trellis / do-it / Assay / CodeStable / Aegis / matt engineering 等外部 skill 包。
