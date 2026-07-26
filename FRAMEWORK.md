# HiQ Framework

## 1. 定位

HiQ 是唯一开发框架。它把项目初始化、会话续作、立项计划、施工、调试、验收、演进、知识沉淀、skill 治理，以及吸收自 Comet 的轻 runtime 状态 / status / doctor / eval / skill harness，收敛成 11 个长期保留的 owner skill；另外提供一个可选的 `hiq-auto` 自动编排 wrapper，用来持续调用真实 owner，但不把 stable owner surface 扩成 12 个。

目标不是“命令更多”，而是：

- 根入口单一
- 生命周期完整
- 状态落盘到 `.hiq/`
- 轻 runtime，重外置状态
- CodeGraph-first
- 完成必须靠证据，而不是聊天记忆

## 2. 基线与状态

项目状态只认本地文件：

- `.hiq/BOOTSTRAP.md`
- `.hiq/MEMORY.md`
- `.hiq/config.yaml`
- `.hiq/session.md`
- `.hiq/current-change.json`
- `.hiq/changes/<id>/...`
- `.hiq/eval/`
- `.hiq/MAP.md`
- `.hiq/graph/*`
- `.codegraph/`

如果本地状态不能让新会话续上，说明框架还没把工作管理好。

## 3. 11 个保留 skill

| Skill | 核心职责 |
|------|----------|
| `hiq` | 根路由 / 定级 / 车道选择 |
| `hiq-init` | 项目基线 / CodeGraph / runtime state / eval scaffold / 续作准备 |
| `hiq-install` | 宿主安装 / runtime sync / codegraph / doctor / 健康校验 |
| `hiq-session` | 开场 / 续作 / status / probe / handoff / compact-safe 恢复 |
| `hiq-grill` | 立项/澄清/研究/架构/计划 |
| `hiq-implement` | 施工 / spec load / slice 执行 / TDD / 隔离 / 委派 |
| `hiq-debug` | 症状冻结 / 根因定位 / 修复闭环 / 防再发 |
| `hiq-review` | 审查/真实验收/放行 |
| `hiq-evolve` | 系统演进（基线/指标/回滚总控） |
| `hiq-knowledge` | ADR/lessons/casebook/audit |
| `hiq-skill` | skill 治理 / 加厚 / 吸收 / 同步 |

### 3.1 可选自动包装层：`hiq-auto`

- `hiq-auto` 不是 retained owner #12
- 它是外层自动入口，负责 goal 驱动、连续选择当前真实 owner、持续推进到验收或诚实阻塞
- 默认 owner 仍然只来自 retained 11
- `hiq-review` 仍然是唯一 completion / acceptance proof owner

## 4. 风险分级

| 级别 | 信号 | 最小流程 |
|------|------|----------|
| L0 Light | 单点、可逆、契约不变 | `hiq` → `hiq-implement` / `hiq-debug` → `hiq-review` |
| L1 Quick | 单模块 | `hiq-session?` → `hiq-grill`(短) → `hiq-implement` → `hiq-review` |
| L2 Standard | 跨模块 / API / 数据 | `hiq-session` → `hiq-grill` → `hiq-implement` → `hiq-review` |
| L3 Heavy | 架构 / 迁移 / 长任务 / 多 owner | `hiq-session` → `hiq-grill`(深) → `hiq-implement`/`hiq-evolve` → `hiq-review` |

## 5. 生命周期总图

```text
hiq-auto       # optional outer goal wrapper; keeps choosing the truthful owner step
   │
   ├─ hiq-install (host + doctor)
   ├─ hiq-init (project baseline + runtime state + CodeGraph + eval scaffold)
   ├─ hiq-session
   ├─ hiq-grill      # synthesize spec + choose seams + approve ticket frontier
   ├─ hiq-implement  # frontier slice execution + public-behavior TDD + slice self-check
   ├─ hiq-debug      # root-cause lane
   ├─ hiq-evolve     # evolution lane
   ├─ hiq-knowledge  # durable memory lane
   └─ hiq-review     # proof gate; required before accepted completion
```

## 6. 根路由算法（`hiq`）

```text
ALWAYS classify L0–L3 (or Goal)
IF host/framework install or runtime sync/repair/health check/doctor → hiq-install
IF no .hiq baseline → hiq-init
IF session start/resume/finish/handoff/profile/status/probe → hiq-session
IF go/no-go unclear OR planning/research/architecture needed → hiq-grill
IF approved IMPLEMENT exists and work is coding / slice execution → hiq-implement
IF bug/root-cause/regression mystery → hiq-debug
IF review/verify/check/demo/eval/closeout needed → hiq-review
IF refactor/migrate/perf/harden/retire/goal evolution → hiq-evolve
IF adr/knowledge/audit capture → hiq-knowledge
IF skill build/upgrade/compose/eval/bundle/publish → hiq-skill
ELSE ASK one focused decision question
```

## 7. 横切铁律

1. **单一框架**：禁止回到 Trellis / do-it 并行工作流。
2. **少而厚**：优先给现有厚 skill 加 mode，不再 proliferate 薄 skill。
3. **Grill 纪律**：事实本地验证，用户只回答决策。
4. **CodeGraph-first**：debug / implement 优先使用 codegraph-rs。
5. **Spec/Ticket/TDD absorbed, not renamed**：`to-spec` / `to-tickets` / `tdd` 这类成熟做法优先内化到 `hiq-grill` / `hiq-implement`。
6. **完成 = 证据**：`hiq-review` 内含 verify/check/demo/eval/closeout，不靠口头完成。
7. **脚本不挑系统**：关键 runtime / init / install / status / doctor surfaces 必须有真实 Windows 入口，不能只靠 bash wrapper 伪兼容。
8. **续作靠本地**：`hiq-session` 负责 checkpoint、status、resume-probe 与 compact-safe 恢复，聊天历史不是主状态。
9. **Debug 先证因后动手**：`hiq-debug` 必须冻结复现、记录假设循环、保护已正确路径。

## 8. 默认文件角色

- `BOOTSTRAP.md`：项目恢复入口
- `MEMORY.md`：持久约束/经验
- `config.yaml`：runtime / review / install 默认配置
- `current-change.json`：机器可读的当前 change 指针
- `session.md`：当前会话与下一步
- `goals/<id>.md`：`hiq-auto` 的外层 goal 编排状态
- `grill.md`：事实/决策/专家板/计划状态
- `IMPLEMENT.md`：批准后的施工契约
- `debug.md`：症状/假设/根因/回归保护/自测循环
- `review.md`：验收矩阵/findings/eval/放行结论
- `install.md`：宿主目标/同步计划/运行时健康/doctor/阻塞原因
- `evidence.md`：新鲜证据
- `eval/`：本地评估配置与运行报告
- `references/cross-platform-smoke.md`：跨平台 smoke 验证矩阵

## 9. 成功标准

HiQ 成功，不是因为 skill 名字多，而是因为：

- 新会话能从本地状态续上
- `hiq-auto` 能把 goal 持续推进到真实 owner，而不是停在半路
- 施工与调试都能诚实路由到唯一主 skill
- bug 修复有根因和回归保护
- 交付放行有真实证据
- 框架能力继续吸收到 11 个保留 owner skill 内，而不是重新膨胀
