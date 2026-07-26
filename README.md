# HiQ

HiQ is an AI engineering framework built around 11 retained owner skills, an optional `hiq-auto` automation wrapper, local project state, CodeGraph-first code understanding, and evidence-based delivery.

HiQ 是一个围绕 11 个保留 owner skill、一个可选的 `hiq-auto` 自动编排入口、本地项目状态、CodeGraph-first 代码理解、以及证据驱动交付构建的 AI 开发框架。

## What HiQ Is | HiQ 是什么

HiQ is not a bag of small prompts. It is a single framework that covers the full lifecycle of software work:

- project bootstrap
- host installation and runtime health
- session recovery and handoff
- planning and architecture
- implementation
- debugging
- review and acceptance
- system evolution
- durable knowledge capture
- framework and skill governance

HiQ 不是一堆零散 prompt 的集合，而是一套完整的软件开发生命周期框架，覆盖：

- 项目初始化
- 宿主安装与运行时健康
- 会话续作与交接
- 立项、澄清与架构规划
- 施工落地
- 缺陷定位与修复
- 审查、验收与放行
- 系统演进
- 长期知识沉淀
- 框架与 skill 治理

## Why HiQ | 为什么用 HiQ

HiQ is opinionated in four ways:

1. **One framework, one active owner**  
   Every request should have one truthful current owner skill.
2. **11 thick skills instead of many thin ones**  
   New capabilities are absorbed into the retained surface instead of multiplying skill names.
   HiQ absorbs patterns like `to-spec`, `to-tickets`, and `tdd` into `hiq-grill` / `hiq-implement` instead of exposing more names.
3. **Local state over chat memory**  
   Work should be resumable from `.hiq/` and related artifacts, not from fragile conversation history.
4. **Evidence before done**  
   "Looks right" is not enough. Delivery claims need fresh proof.

HiQ 有四个非常明确的设计取向：

1. **单一框架，单一当前 owner**  
   每个请求在任一时刻都应有一个真实的当前主 skill。
2. **11 个厚 skill，而不是几十个薄 skill**  
   新能力优先吸收到保留表面，而不是继续膨胀名字数量。
   像 `to-spec`、`to-tickets`、`tdd` 这样的成熟模式，也优先内化到 `hiq-grill` / `hiq-implement`，而不是继续新增名字。
3. **本地状态优先于聊天记忆**  
   工作应当能从 `.hiq/` 等本地文件恢复，而不是依赖脆弱的上下文历史。
4. **完成必须靠证据**  
   代码“看起来对”不等于交付完成，必须有当前修订对应的新鲜证明。

## The 11 Retained Skills | 11 个保留 Skill

| Skill | Primary Role | 主要职责 |
|---|---|---|
| `hiq` | root router | 根路由、定级、选当前主 skill |
| `hiq-init` | project bootstrap | 项目基线、`.hiq/`、CodeGraph、eval scaffold |
| `hiq-install` | host/runtime install | 宿主安装、runtime sync、doctor、健康校验 |
| `hiq-session` | continuity | 开场、续作、status、handoff、checkpoint |
| `hiq-grill` | planning | 立项、澄清、研究、架构、计划、`IMPLEMENT.md` |
| `hiq-implement` | execution | 按批准契约施工、slice 执行、TDD、隔离、委派 |
| `hiq-debug` | debugging | 症状冻结、根因定位、修复闭环、回归保护 |
| `hiq-review` | proof/release | 审查、证据、eval、验收、放行 |
| `hiq-evolve` | evolution | 重构、迁移、性能、加固、退役、目标演进 |
| `hiq-knowledge` | durable memory | ADR、lessons、casebook、audit |
| `hiq-skill` | framework governance | skill 加厚、能力吸收、bundle、publish、sync |

Detailed skill guidance lives in [SKILL_CATALOG.md](./SKILL_CATALOG.md).

完整的 skill 能力、触发条件、模式和调用示例见 [SKILL_CATALOG.md](./SKILL_CATALOG.md)。

Optional wrapper:

- `hiq-auto` is an automation entrypoint, not retained owner #12.
- It creates or refreshes a goal record, keeps selecting the truthful current owner from the retained 11, and does not stop until `hiq-review` proves acceptance or a real blocker is recorded.

可选自动入口：

- `hiq-auto` 是自动编排 wrapper，不是第 12 个 retained owner。
- 它会创建或刷新 goal 记录，持续在 retained 11 中选择当前真实 owner，并一直推进到 `hiq-review` 证明验收通过，或诚实记录真实阻塞。

## One-Line Prompt | 一句话安装词

Send this sentence directly to Codex / Claude / LiveAgent:

```text
请把当前仓库安装并配置为 HiQ：先完成宿主级 HiQ 安装与 skill 同步，再完成项目级 HiQ 初始化，启用 hiq-auto 自动模式，并验证 hiq-status / hiq-doctor 通过；如果缺少任何必要配置或脚本，请直接补齐，直到可以开始用 HiQ 正常开发为止。
```

把上面这句话直接发给 Codex / Claude / LiveAgent，就可以让 AI 直接开始 HiQ 的安装、配置和初始化流程。

## Automatic Mode | 自动模式

```text
$hiq-auto
# auto goal loop -> choose current owner -> keep going until acceptance
```

```text
$hiq-auto
# 自动进入 goal 循环 -> 选择当前 owner -> 一直推进到验收达标
```

## Typical Flow | 典型流程

```text
hiq-install   -> install or refresh the framework runtime on the host
hiq-init      -> initialize a project with HiQ local state and CodeGraph
hiq-session   -> rebuild or normalize the working session
hiq-grill     -> synthesize the spec, lock seams, and approve the ticket frontier
hiq-implement -> execute the approved frontier slices with TDD when behavior lock matters
hiq-review    -> prove the result and decide release readiness
```

```text
hiq-install   -> 安装或刷新宿主上的 HiQ runtime
hiq-init      -> 在项目中建立 HiQ 本地状态与 CodeGraph
hiq-session   -> 重建或规范当前工作会话
hiq-grill     -> 综合当前事实产出 spec、确认 seam、批准 ticket frontier
hiq-implement -> 按批准的 frontier slice 施工，并在需要时用 TDD 锁行为
hiq-review    -> 用证据验证结果并决定是否放行
```

Absorbed engineering patterns:

- `hiq-grill` now owns spec synthesis from known truth, seam-first planning, and ticket frontier design.
- `hiq-implement` now owns frontier-only slice execution, public-behavior TDD, and the wide-refactor exception rule.

已吸收的工程化模式：

- `hiq-grill` 负责基于已知事实综合 spec、先定 seam、再设计 ticket frontier。
- `hiq-implement` 负责只拿当前 frontier slice 施工、优先做 public-behavior TDD、并约束 wide-refactor 例外。

Special lanes:

- bug or unexplained failure -> `hiq-debug`
- refactor, migration, performance, hardening -> `hiq-evolve`
- durable ADR/lessons/audit capture -> `hiq-knowledge`
- framework/skill changes -> `hiq-skill`

特殊车道：

- bug、异常、根因未明 -> `hiq-debug`
- 重构、迁移、性能、加固 -> `hiq-evolve`
- ADR、经验规则、审计沉淀 -> `hiq-knowledge`
- 框架和 skill 自身演进 -> `hiq-skill`

## Quick Start | 快速开始

### For Daily Product Work | 日常产品开发

```text
$hiq-init
$hiq-auto
# manual lane when needed: $hiq / $hiq-debug / $hiq-evolve / ...
```

Example:

```text
$hiq-auto Add an export button to the settings page and keep going until acceptance
$hiq-debug Intermittent duplicate payment callback processing
$hiq-evolve Migrate Express to Fastify without breaking one major API version
```

示例：

```text
$hiq-auto 给设置页加一个导出按钮，并一直推进到验收通过
$hiq-debug 支付回调偶发重复入账
$hiq-evolve Express 迁移到 Fastify，同时保持一个大版本的 API 兼容
```

### For Framework Maintainers | 框架维护者

```text
$hiq-install
bash "$HOME/.hiq/scripts/hiq-status.sh" .
bash "$HOME/.hiq/scripts/hiq-doctor.sh" .
bash plugins/hiq/scripts/hiq-smoke.sh
# Windows
%USERPROFILE%\\.hiq\\scripts\\hiq-status.cmd .
%USERPROFILE%\\.hiq\\scripts\\hiq-doctor.cmd .
plugins\hiq\scripts\hiq-smoke.cmd
```

Use `hiq-install` when the framework source changes and installed host/runtime copies must be refreshed.
Run `hiq-smoke` after runtime, init, MCP, or portability changes so health claims stay evidence-backed.

当框架源码发生变化、需要同步已安装的宿主副本和 runtime 副本时，使用 `hiq-install`。

## Repository Layout | 仓库结构

| Path | Purpose |
|---|---|
| `plugins/hiq/skills/` | the 11 retained owner skills plus the optional `hiq-auto` wrapper |
| `plugins/hiq/scripts/` | helper scripts for install, status, doctor, and CodeGraph |
| `plugins/hiq/references/` | shared references, rules, routing maps, and templates |
| `plugins/hiq/vendor/` | pinned runtime dependencies such as `codegraph-rs` metadata |
| `.hiq/` | self-hosted HiQ project state for this framework repo |
| `FRAMEWORK.md` | framework principles and routing model |
| `SKILL_CATALOG.md` | detailed skill-by-skill guide |
| `ANALYSIS.md` | background analysis and replacement reasoning |

## Design Principles | 设计原则

- **HiQ is the only framework**: no parallel Trellis / do-it / scattered workflow packages.
- **Cross-platform by default**: HiQ should not assume macOS/Linux only; key runtime surfaces must have truthful Windows paths too.
- **CodeGraph-first**: shared-symbol understanding and impact analysis come before risky edits.
- **Compact-safe continuity**: when context pressure rises, checkpoint first, then switch sessions.
- **Fresh proof**: review and release should cite current evidence, not memory.
- **Stable public surface**: retain the 11 owner skills; `hiq-auto` may wrap them, but should not replace them.

- **HiQ 是唯一框架**：不再并行依赖 Trellis、do-it 或散装 workflow。
- **CodeGraph-first**：共享符号、调用链和影响面先看清，再做高风险修改。
- **Compact-safe 续作**：上下文压力升高时，先写 checkpoint，再切换会话。
- **新鲜证据优先**：审查和放行要基于当前证据，而不是记忆或感觉。
- **公开表面稳定**：保留 11 个 owner skill；`hiq-auto` 可以做外层自动编排，但不替代 owner 本身。

## Related Documents | 相关文档

- [FRAMEWORK.md](./FRAMEWORK.md)
- [SKILL_CATALOG.md](./SKILL_CATALOG.md)
- [ANALYSIS.md](./ANALYSIS.md)
- [plugins/hiq/references/replacement-map.md](./plugins/hiq/references/replacement-map.md)
- [plugins/hiq/references/cross-platform-smoke.md](./plugins/hiq/references/cross-platform-smoke.md)

## Engine | 引擎

HiQ bundles and manages [Cleboost/codegraph-rs](https://github.com/Cleboost/codegraph-rs) as its code intelligence engine.

HiQ 使用并管理 [Cleboost/codegraph-rs](https://github.com/Cleboost/codegraph-rs) 作为代码图谱与代码理解引擎。

## License | 许可证

MIT
