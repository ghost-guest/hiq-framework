# Root routing table (11-skill edition)

| User signal | Route | Lane |
|-------------|-------|------|
| auto、autopilot、goal、端到端完成、一直推进到验收通过、keep going until accepted | `hiq-auto` | automation |
| 开会话、开始工作、resume、finish、handoff、profile、checkpoint 恢复、status、resume probe | `hiq-session` | session |
| 产品仓初始化 / 工程记忆 / CodeGraph / 吸收旧框架 / runtime state scaffold / eval scaffold | `hiq-init` | init |
| 安装/升级 HiQ 到宿主；runtime sync；codegraph/runtime repair；宿主健康校验；doctor | `hiq-install` | host |
| 立项、Proceed/Research/Defer、目标不清、验收不清、研究、架构、接口、术语、切片、可实施计划 | `hiq-grill` | planning |
| 按 IMPLEMENT / slice 写代码，且 scope/acceptance 已清楚；需要 spec load / TDD / isolate / delegate | `hiq-implement` | execution |
| 原因不明、bug、回归、修了还坏、防再发 | `hiq-debug` | debug |
| 审查、fix-loop、verify、check、demo、eval、closeout、是否可放行 | `hiq-review` | proof |
| refactor / migrate / perf / harden / retire / goal | `hiq-evolve` | evolution |
| ADR、lesson、casebook、audit、知识沉淀 | `hiq-knowledge` | memory |
| 保留 skill 加厚、能力吸收、compose/eval/bundle/publish、框架同步、new-skill proposal 治理 | `hiq-skill` | governance |
| 其它未指定开发请求 | `hiq` | root |

## Tie-break rules

1. 缺 `.hiq/` 基线 -> `hiq-init`
2. 续作入口不明 -> `hiq-session`
3. 真正 blocker 是原因不明 -> `hiq-debug`
4. 真正 blocker 是 scope/acceptance/plan 不清 -> `hiq-grill`
5. 已准备好按批准 IMPLEMENT 直接施工 -> `hiq-implement`
6. 主要问题是证明是否完成 -> `hiq-review`

## Root rules

- `hiq-auto` 可以做外层自动编排，但当前真实 owner 仍然只能是一个 retained skill
- `hiq` 任一时刻只激活一个当前主 skill
- 用户显式点名 skill 时，若与真实任务冲突，以真实 owner 为准
- Ambiguous but locally resolvable -> 本地验证，不问用户
- Ambiguous and still not honest after local check -> 最多 1 个决策问题
- Never route to removed thin skills or external parallel frameworks
