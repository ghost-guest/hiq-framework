# HiQ Skill Catalog

This file explains what each retained HiQ owner skill does, plus the optional `hiq-auto` wrapper, when to use them, which modes matter, and what a normal invocation looks like.

本文件用于解释 HiQ 每个保留 owner skill，以及可选的 `hiq-auto` 自动 wrapper 的职责、适用场景、常见模式，以及日常应如何调用。

## Quick Index | 快速索引

| Skill | Short Role | 简述 |
|---|---|---|
| `hiq-auto` | auto goal wrapper | 自动目标编排入口 |
| `hiq` | root routing | 根路由与主 skill 选择 |
| `hiq-init` | project bootstrap | 项目初始化与基线建立 |
| `hiq-install` | host/runtime install | 宿主安装与运行时同步 |
| `hiq-session` | session continuity | 会话续作、状态与交接 |
| `hiq-grill` | planning contract | 立项、研究、架构与计划契约 |
| `hiq-implement` | execution | 执行批准方案并产出结果 |
| `hiq-debug` | root-cause repair | 根因定位与修复闭环 |
| `hiq-review` | proof and release | 审查、验收、证据与放行 |
| `hiq-evolve` | system evolution | 重构、迁移、性能和加固 |
| `hiq-knowledge` | durable knowledge | ADR、经验、案例与审计 |
| `hiq-skill` | framework governance | skill 治理、自进化与发布 |

## 0. `hiq-auto`

**Capability | 能力**

- Acts as the automatic outer wrapper for HiQ-managed project work.
- Creates or refreshes a durable goal record under `.hiq/goals/`.
- Repeatedly chooses the truthful current owner from the retained 11 and keeps going until acceptance is proven.
- Routes back to `hiq-grill` when a goal still lacks approved spec, seam, or ticket-frontier truth.

- 作为 HiQ 项目工作的自动外层 wrapper。
- 在 `.hiq/goals/` 下创建或刷新 durable goal 记录。
- 持续从 retained 11 中选择当前真实 owner，并一直推进到验收被证明通过。
- 当目标还缺少已批准的 spec、seam 或 ticket frontier 时，会先退回 `hiq-grill`。

**Use it when | 什么时候用**

- The project enables auto mode by rule.
- The user wants end-to-end delivery, autopilot behavior, or goal-driven continuation.
- You want HiQ to keep orchestrating the next honest step instead of stopping after one lane.

- 项目规则启用了 auto mode。
- 用户想要端到端推进、autopilot 行为或 goal-driven 续作。
- 你希望 HiQ 不停在单个车道里，而是持续编排下一步真实 owner。

**Common modes | 常用模式**

- `auto`
- `goal`
- `continue`
- `override`
- `handoff`

**Examples | 示例**

```text
$hiq-auto Ship this feature and keep going until review-backed acceptance
$hiq-auto 把这个需求一路推进到验收通过为止
```

## 1. `hiq`

**Capability | 能力**

- Routes every incoming request to the smallest truthful next skill.
- Classifies work into `L0`, `L1`, `L2`, `L3`, or `Goal`.
- Prevents multiple retained skills from being half-active at the same time.

- 把每个请求路由到“最小但真实”的下一步 skill。
- 将任务定级为 `L0`、`L1`、`L2`、`L3` 或 `Goal`。
- 防止多个保留 skill 同时半激活、互相踩边界。

**Use it when | 什么时候用**

- The user gives a normal development request without naming a specific skill.
- The task is mixed, messy, or ambiguous.
- You need to re-enter work and first decide which owner skill is honest now.

- 用户直接给了一个开发请求，但没有明确点 skill。
- 任务混杂、含糊、边界还不清楚。
- 你需要恢复工作，但得先决定现在真实的 owner 是谁。

**Common modes | 常用模式**

- `route`
- `triage`
- `resume-check`
- `handoff`

**Examples | 示例**

```text
$hiq Add CSV export to the admin report page
$hiq 帮我看下这个需求应该先规划还是直接改
```

## 2. `hiq-init`

**Capability | 能力**

- Creates or refreshes the `.hiq/` local state.
- Installs or refreshes project-side CodeGraph and wiring.
- Prepares a repo so a future session can continue from files instead of chat history.

- 创建或刷新 `.hiq/` 本地状态。
- 安装或刷新项目侧的 CodeGraph 与相关连线。
- 让仓库具备“未来新会话可只靠本地文件继续”的能力。

**Use it when | 什么时候用**

- A new repo needs HiQ baseline files.
- `.hiq/` is missing, stale, or incomplete.
- Legacy workflow material should be absorbed into HiQ.

- 新仓库需要接入 HiQ。
- `.hiq/` 缺失、过期或不完整。
- 旧工作流资料要迁移到 HiQ。

**Common modes | 常用模式**

- `init`
- `refresh`
- `absorb`

**Examples | 示例**

```text
$hiq-init
$hiq-init refresh this repo and rebuild its CodeGraph baseline
```

## 3. `hiq-install`

**Capability | 能力**

- Installs or upgrades HiQ on the host machine or agent environment.
- Syncs retained skills, scripts, references, and bundled runtime assets.
- Verifies runtime readiness with `status`, `verify`, and `doctor` style checks.

- 在宿主机器或 Agent 环境中安装或升级 HiQ。
- 同步保留 skill、脚本、参考资料和 bundled runtime 资产。
- 用 `status`、`verify`、`doctor` 风格检查证明运行时可用。

**Use it when | 什么时候用**

- The framework needs to be installed on a machine.
- The source framework changed and installed host copies are stale.
- You need to diagnose or repair runtime drift.

- 需要把框架装到某台机器或某个 Agent 宿主上。
- 框架源码变了，已安装副本需要刷新。
- 需要诊断或修复 runtime 漂移。

**Common modes | 常用模式**

- `preview`
- `apply`
- `repair`
- `sync`
- `verify`
- `doctor`

**Examples | 示例**

```text
$hiq-install
$hiq-install sync runtime copies after framework changes
```

## 4. `hiq-session`

**Capability | 能力**

- Rebuilds session state from local files.
- Writes checkpoints and handoff packets.
- Emits compact operational status and resume probes.

- 从本地文件重建当前会话状态。
- 写 checkpoint 与 handoff 恢复包。
- 输出紧凑的状态快照和 resume probe。

**Use it when | 什么时候用**

- Starting, resuming, continuing, or finishing work.
- Context is getting dangerous and you need a checkpoint.
- You want a status snapshot from local state only.

- 开始、恢复、继续或结束当前工作。
- 上下文开始危险，需要先写 checkpoint。
- 你想只基于本地状态拿到一个状态快照。

**Common modes | 常用模式**

- `start`
- `resume`
- `continue`
- `finish`
- `handoff`
- `profile`
- `status`
- `resume-probe`

**Examples | 示例**

```text
$hiq-session
$hiq-session resume
$hiq-session handoff
```

## 5. `hiq-grill`

**Capability | 能力**

- Turns unclear requests into an explicit execution contract.
- Synthesizes the spec from known repo truth and conversation context.
- Verifies local facts before asking the user decision questions.
- Chooses the highest useful seam before ticketing.
- Produces `grill.md` and approval-ready `IMPLEMENT.md` with ticket frontier and blocking edges.

- 把不够清晰的请求整理成明确的执行契约。
- 基于仓库已知事实和当前对话综合出 spec。
- 先验证本地事实，再问用户真正需要拍板的问题。
- 在切 ticket 前先确定最有价值的 seam。
- 产出 `grill.md` 和可批准的 `IMPLEMENT.md`，其中包含 ticket frontier 和 blocking edges。

**Use it when | 什么时候用**

- Scope, acceptance, seam, or approach is still unclear.
- Research, architecture, interface, or domain pressure matters.
- The work needs a real spec and ticket frontier before coding.
- There are multiple valid approaches and a real trade-off exists.

- 范围、验收标准、seam 或实现路线还不清楚。
- 需要研究、架构、接口或领域澄清。
- 编码前需要先形成真实的 spec 和 ticket frontier。
- 有多个可行方案，确实存在取舍。

**Common modes | 常用模式**

- `triage`
- `research`
- `grill`
- `refresh`
- `handoff`

**Examples | 示例**

```text
$hiq-grill Plan a multi-tenant billing export workflow
$hiq-grill 先帮我把这个需求整理成可执行计划
```

## 6. `hiq-implement`

**Capability | 能力**

- Executes approved work one frontier slice at a time.
- Loads contract, spec, seam plan, and graph context before risky edits.
- Prefers public-behavior TDD when behavior lock matters.
- Supports isolation and bounded delegation.
- Treats wide refactors as an explicit exception, not the default execution shape.

- 按批准后的契约逐个 frontier slice 执行。
- 在高风险修改前装载契约、spec、seam 计划和图谱上下文。
- 在需要锁行为时优先采用 public-behavior TDD。
- 支持隔离 worktree 和边界清晰的委派。
- 把 wide refactor 视为明确例外，而不是默认施工形态。

**Use it when | 什么时候用**

- An approved `IMPLEMENT.md` exists.
- The next honest step is coding, not more planning.
- The next unblocked frontier slice is ready to execute.
- The work needs disciplined execution and progress tracking.

- 已经有批准过的 `IMPLEMENT.md`。
- 下一步真实动作是写代码，而不是继续规划。
- 下一个未阻塞的 frontier slice 已经可以执行。
- 工作需要规范的执行和进度收口。

**Common modes | 常用模式**

- `execute`
- `tdd`
- `isolate`
- `delegate`
- `handoff`

**Examples | 示例**

```text
$hiq-implement
$hiq-implement execute slice 2 from IMPLEMENT.md
```

## 7. `hiq-debug`

**Capability | 能力**

- Freezes the symptom and narrows the repro.
- Uses CodeGraph-first root-cause mapping.
- Protects known-good paths while fixing the real cause.

- 冻结症状并收窄复现路径。
- 用 CodeGraph-first 方式定位根因。
- 在修根因时保护已经正确的路径不被回归破坏。

**Use it when | 什么时候用**

- A bug, regression, flaky failure, or unexplained behavior appears.
- Tests are failing but the cause is still unclear.
- Previous fixes did not hold.

- 出现 bug、回归、偶发失败或无法解释的行为。
- 测试挂了，但真正原因还不清楚。
- 之前的修法没站住，问题反复出现。

**Common modes | 常用模式**

- `diagnose`
- `fix`
- `regress`
- `break-loop`
- `handoff`

**Examples | 示例**

```text
$hiq-debug Find why the webhook retries duplicate records
$hiq-debug 线上偶发超时，但还没找到根因
```

## 8. `hiq-review`

**Capability | 能力**

- Reviews a materially done change against its contract.
- Builds an acceptance matrix and evidence map.
- Decides whether the change is ready to ship, needs more proof, or must go back.

- 基于契约审查“基本做完”的变更。
- 建立验收矩阵和证据映射。
- 判断是否可以放行、是否需要补证据、或必须退回继续改。

**Use it when | 什么时候用**

- Someone says the work is done or ready.
- You need findings, verification, demo proof, eval proof, or closeout.
- The main question is pass/fail, not what to implement next.

- 有人说“做完了”或“可以发了”。
- 需要 findings、验证、demo、eval 或 closeout。
- 当前核心问题是能不能过，而不是下一步写什么。

**Common modes | 常用模式**

- `review`
- `fix-loop`
- `verify`
- `demo`
- `eval`
- `closeout`
- `handoff`

**Examples | 示例**

```text
$hiq-review
$hiq-review verify the acceptance proof for this change
```

## 9. `hiq-evolve`

**Capability | 能力**

- Manages system-level improvement work such as refactors, migrations, performance, hardening, and retirement.
- Names baseline, target, rollout, rollback, and compatibility truth.
- Routes execution and review honestly around those evolution constraints.

- 管理系统级演进工作，如重构、迁移、性能优化、加固和退役。
- 明确 baseline、目标、rollout、rollback 和兼容性边界。
- 围绕这些演进约束，诚实地组织执行与验收。

**Use it when | 什么时候用**

- The goal is to improve or reshape the system, not add a normal feature.
- Rollout and rollback matter as much as code changes.
- The task is operationally or structurally sensitive.

- 目标是改进或重塑系统，而不是新增普通功能。
- rollout / rollback 与代码本身同等重要。
- 任务具有结构性或运行层面的敏感性。

**Common modes | 常用模式**

- `refactor`
- `migrate`
- `perf`
- `harden`
- `retire`
- `goal`
- `handoff`

**Examples | 示例**

```text
$hiq-evolve Migrate Redis cache invalidation to an event-driven pipeline
$hiq-evolve 做一轮 API 网关性能和可观测性加固
```

## 10. `hiq-knowledge`

**Capability | 能力**

- Captures durable knowledge that should survive beyond the current chat.
- Separates ADRs, reusable lessons, multi-attempt casebooks, and audits.
- Feeds future sessions with artifacts worth reading.

- 沉淀应该跨会话保留的长期知识。
- 区分 ADR、复用规则、多轮失败案例和审计结果。
- 为未来会话提供真正值得读的知识材料。

**Use it when | 什么时候用**

- A durable architecture or policy decision was made.
- A fix took multiple meaningful attempts.
- A new reusable rule should become part of project memory.

- 做出了长期有效的架构或策略决策。
- 一个问题经历了多轮有意义的失败尝试才修好。
- 出现了一条值得沉淀到项目记忆中的复用规则。

**Common modes | 常用模式**

- `adr`
- `lesson`
- `casebook`
- `audit`
- `handoff`

**Examples | 示例**

```text
$hiq-knowledge Write a lesson from this flaky queue consumer fix
$hiq-knowledge 把这次多轮排查写进 casebook
```

## 11. `hiq-skill`

**Capability | 能力**

- Governs the framework itself.
- Thickens retained skills instead of reviving thin ones.
- Keeps skill docs, routing, templates, scripts, bundle outputs, and host copies in sync.

- 治理 HiQ 框架本身。
- 优先把能力吸收到保留 skill，而不是复活薄 skill。
- 保持 skill 文档、路由、模板、脚本、bundle 产物和宿主副本一致。

**Use it when | 什么时候用**

- A retained skill is too thin or drifted from the rest of the framework.
- A capability should be absorbed into HiQ instead of becoming a new surface.
- You need bundle, eval, publish, or framework sync work.

- 某个保留 skill 太薄，或与框架其他部分漂移了。
- 某项能力应该被 HiQ 吸收，而不是变成新表面。
- 需要做 bundle、eval、publish 或框架同步。

**Common modes | 常用模式**

- `upgrade`
- `absorb`
- `compose`
- `eval`
- `bundle`
- `publish`
- `build`
- `sync`

**Examples | 示例**

```text
$hiq-skill Absorb this thin planning helper into hiq-grill
$hiq-skill Prepare the retained 11 for external publish
```

## Rule of Thumb | 一个简单判断法

If the project is in auto mode, start with `hiq-auto`.

If the work is unclear and you are not using the auto wrapper, start with `hiq`.

If the work is clear but still needs a spec, seam, or ticket frontier, go to `hiq-grill`.

If the contract is approved and the next unblocked frontier slice is code, use `hiq-implement`.

If the problem is a failure with unclear cause, use `hiq-debug`.

If the work is materially done and the real question is proof, use `hiq-review`.

如果不知道该用哪个 skill，就先从 `hiq` 开始。

如果目标大致清楚，但还缺 spec、seam 或 ticket frontier，用 `hiq-grill`。

如果契约已经批准，下一步真实动作是执行下一个未阻塞的 frontier slice，用 `hiq-implement`。

如果问题是异常或故障，而且根因还不清楚，用 `hiq-debug`。

如果工作基本完成，核心问题变成“能不能验收”，用 `hiq-review`。
