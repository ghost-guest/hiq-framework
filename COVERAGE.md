# 源项目精髓覆盖审计

对照你提供的仓库 + 已声明要吸收的 Trellis/do-it。状态：`covered` / `partial` / `gap`。

## 总表

| # | 来源 | 精髓 | HiQ 承载 | 状态 |
|---|------|------|----------------|------|
| 1 | **Assay** | 外部证据→分析→adopt/reject/experiment/ADR→knowledge；provenance；overlay/standalone 心智 | `hiq-study` + `hiq-adr` + `hiq-keep` + onboard absorb | **covered**（无独立 living-source sync CLI，刻意薄） |
| 2 | **architecture-copilot** | 七阶段共创、灵魂六问、先问后答、反挑战、读图四步 | `hiq-architect` + `soul-six-questions.md` | **covered** |
| 3 | **Rasen** | propose→apply→archive；pipeline 类型；goal 条件螺旋；handoff/context | change 目录 + `hiq-feature`/`hiq-goal`/`hiq-handoff` | **covered**（无 YAML pipeline 引擎/chrome-use，刻意薄） |
| 4 | **Headroom** | 工具输出/日志压缩进上下文前处理；可逆检索原则 | iron-laws context hygiene + handoff；**无压缩 proxy** | **partial**（原则有，运行时压缩层无——属 infra 非 skill） |
| 5 | **ExpertTeam-Codex** | 领域专家路由：软件/设计/产品/运维/安全/DB | `hiq` 路由 + harden/perf/architect/domain… | **partial→accept**（开发框架覆盖工程域；设计/产品/PIPL 整团不纳入 v0.3） |
| 6 | **codex-keysmith** | dry-run、备份、manifest、recover；**拒绝** jailbreak 指令 | `hiq-init` 备份安装；onboard dry 语义 | **covered**（只采纳运维模式） |
| 7 | **Aegis** | baseline-first；evidence-before-done；七层根因；反熵增/退役；fast path；长任务续接 | iron-laws + `hiq-verify`/`hiq-debug`/`hiq-retire`/`hiq-handoff` + L0 保护 | **covered** |
| 8 | **COMPASS** | clarifier；task forest/DAG；handoff；profile；skill build/upgrade | `hiq-grill`/`hiq-handoff`/`hiq-profile`/`hiq-skill-*`；tasks/changes 作森林 | **covered**（task-forest 用 changes+tasks+session，非独立 DAG UI） |
| 9 | **CodeStable** | 软件实体中心；根路由；Quick/Standard/Goal；issue/refactor；compound；人在环 | `.hiq/` 实体 + `hiq`/`hiq-feature`/`hiq-issue`/`hiq-refactor`/`hiq-keep` | **covered**（无 eval-cs-skill 评测引擎，刻意薄） |
| 10 | **web-dev-skills / T-Tools** | Decision→PRD→design→phase task→run→demo accept；人校准；可选 check | `hiq-grill` + `hiq-feature` + `hiq-demo` + slice/check | **covered**（口播模板未逐字搬运，决策/demo 门已有） |

## 额外吸收（你要求完全替代）

| 来源 | 精髓 | 承载 | 状态 |
|------|------|------|------|
| Trellis | session/continue/finish/spec/check/break-loop | `hiq-session` 等 | **covered** |
| do-it | router/grill/slice/fix-loop/verify/interface/arch-scan/domain/worktree/delegate/closeout | 对应 hiq-* | **covered** |

## 刻意不覆盖（说明）

| 项 | 原因 |
|----|------|
| Headroom 压缩 proxy/MCP | 独立运行时依赖，不是 skill 协议 |
| ExpertTeam 设计/产品/PIPL 整团 | 你要的是**开发框架**；设计/产品战略可后续 `hiq-skill-build` 扩展 |
| Rasen autopilot LEAD / chrome-use | 重 harness；HiQ 用人在环 + delegate |
| CodeStable skill 评测实验床 | 可后加，不阻塞 OS |
| keysmith 解除限制 prompt | 明确拒绝 |

## 本次已补

1. `hiq-init` — 用户零命令，Agent 安装  
2. `hiq-grill` / `hiq-demo` — T-Tools 立项与路径验收  
3. `COVERAGE.md` 审计表  
4. **Depth wave 1** — `skill-schema` + S2：`hiq-session` / `hiq-feature` / `hiq-issue` / `hiq-verify` / `hiq-skill-build`  
5. **`hiq-grill` 0.7.1–0.7.2** — 含 brainstorm/plan；已删除独立 `hiq-plan` / `hiq-brainstorm`

## Skill 深度（非仅目录存在）

| 主轴 skill | 深度目标 | 状态 |
|------------|----------|------|
| hiq-init | S3 | done |
| hiq-session | S2 | **done (0.7.0)** |
| hiq-feature | S2 | **done (0.7.0)** |
| hiq-issue / hiq-verify | S2 | **done (0.7.0)** |
| hiq-implement / check / debug / migrate / perf | S2 | pending wave 2 |
| 其余 catalog | ≥S1 | many still S0/S1 thin |

## 结论

| 层级 | 覆盖 |
|------|------|
| 开发全生命周期主轴（命名） | **完整** |
| 主轴可执行深度 | **wave 1 进行中**（session/feature/issue/verify 已 S2） |
| 10 源项目工程精髓 | **9 covered / 1 partial(Headroom infra) / Expert 非工程团 accept-out** |
| Trellis + do-it 替代 | **完整（协议层）；深度对齐 wave 2+** |
| 用户安装体验 | **`$hiq-init`，无需手跑 shell** |
