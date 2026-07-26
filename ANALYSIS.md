# 来源项目精华分析

分析日期：2026-07-20。目的：提炼可复用机制，而非抄目录。

## 总览对照

| 项目 | 核心实体 | 最强贡献 | 刻意不采用 |
|------|----------|----------|------------|
| [Assay](https://github.com/X-T-E-R/assay) | source / analysis / ADR / knowledge / system | 外部学习 → 决策 → 知识的证据闭环；overlay/standalone | 完整 CLI 依赖（可选用，skill 只借语义） |
| [architecture-copilot](https://github.com/study8677/architecture-copilot) | 约束 / 取舍 / ADR | 先问后答七阶段；灵魂六问；反挑战 | 无状态纯对话（我们要落盘） |
| [Rasen](https://github.com/DumoeDss/rasen) | change / propose-apply-archive | Spec 驱动变更；pipeline 类型化；goal 条件螺旋；handoff | 重型 autopilot harness 全量绑定 |
| [Headroom](https://github.com/headroomlabs-ai/headroom) | compressed context | 工具输出/日志压缩；可逆检索 | 不进业务 skill 表，作可选 infra |
| [ExpertTeam-Codex](https://github.com/ReJeCtAll/ExpertTeam-Codex) | team / expert router | 领域专家路由（软件/设计/产品/运维/安全/DB） | 重角色扮演与多 agent 名分 |
| [codex-keysmith](https://github.com/Jia-Ethan/codex-keysmith) | config deploy | dry-run、备份、manifest、recover 事务 | **不采用**其「解除限制」指令哲学 |
| [Aegis](https://github.com/GanyuanRan/Aegis) | baseline / evidence / drift | baseline-first；完成前证据；七层根因；反熵增/退役；fast path | 多宿主装机复杂度 |
| [COMPASS](https://github.com/dongshuyan/compass-skills) | profile / task forest / handoff | 澄清门；任务 DAG；会话交接；skill 自进化 | 学术润色 skill 非工程主线 |
| [CodeStable](https://github.com/codestable/CodeStable) | req / epic / feature / issue / decision | **人在环 + 软件要素中心**；根路由；Quick/Standard/Goal；skill 评测闭环 | 完整 32 skill 照搬（过重） |
| [web-dev-skills / T-Tools](https://github.com/timzaak/web-dev-skills) | PRD / design / phase task | 阶段门（backend→frontend→demo）；人校准口播；check 可选 | 强绑定 Rust/React 栈细节 |

## 逐项精华

### 1. Assay — 证据工作台

- **循环**：sources → analysis + checks → adopt/reject/experiment/ADR → knowledge/systems
- **模式**：standalone 研究仓 vs overlay 挂在产品仓的私有 `.assay/`
- **Adopt**：旧项目迁入有 dry-run / apply，不直接污染产品 git
- **对 HiQ**：`hiq-study` + `hiq-migrate` 的「外部证据与迁移动作」语义；`knowledge/` 与 ADR 生命周期

### 2. architecture-copilot — 架构教练

- 七阶段：开场 → 范围减法 → 灵魂六问 → 信封估算 → 质量属性排序 → 关键决策追问 → 收敛 → 反挑战
- 铁律：一次一维、追问代价、不做语言/框架争论
- **对 HiQ**：`hiq-architect` 全文采用；产出写入 `.hiq/architecture/` + ADR

### 3. Rasen — 螺旋而非圆圈

- propose → apply → archive 变更模型
- pipeline：small-feature / bug-fix / full-feature / auto-decompose（YAML 数据驱动）
- `/goal`：done = 条件（指标/rubric），不是文档写完
- handoff / context sensing：长任务续接
- **对 HiQ**：`hiq-feature` 通道类型；`hiq-goal`；`hiq-handoff`；变更目录 `changes/`

### 4. Headroom — 上下文压缩层

- 内容路由压缩 JSON/代码/日志；可逆 CCR
- **对 HiQ**：原则写进全局规则：大日志/工具输出先摘要落盘，禁止整段糊进对话

### 5. ExpertTeam — 领域路由

- 软件 / 设计 / 产品 / 运维 / 安全 / 数据库 专家入口 + 总路由
- **对 HiQ**：`hiq` 路由表带 domain hint；`hiq-harden` 覆盖安全/运维；不复制整团 agent 剧本

### 6. codex-keysmith — 配置部署工程（仅运维模式）

- dry-run 默认、备份、ownership manifest、中断 recover
- **对 HiQ**：`install.sh` 与 `hiq-onboard` 的安全安装语义
- **明确拒绝**：任何「全局解除模型安全边界」的指令包

### 7. Aegis — 方法包纪律

- baseline-first；verification-before-completion
- 系统调试七层；第一性原理审查新 owner
- anti-entropy：改后检查复杂度与旧路径退役
- 渐进成本：小任务 fast path
- **对 HiQ**：横切铁律；`hiq-debug` / `hiq-verify` / `hiq-retire` / `hiq-review`

### 8. COMPASS — 个人对齐 OS

- task-clarifier / task-forest / session-handoff / user-profile
- run-history → skill-builder / skill-upgrader（需人工批准）
- **对 HiQ**：`hiq-clarify` / `hiq-handoff` / `hiq-profile` / skill 工程双 skill

### 9. CodeStable — 严肃工程主轴（最大权重）

- 编排 **Requirement / Architecture / Feature / Issue / Decision**，不是 Agent 队伍
- 根入口 `cs`：行动直转、咨询只建议
- feature 三通道 Quick / Standard / Goal
- issue / refactor 端到端 + 横切 code-review
- compound 知识 + attention 短约定
- skill 用 Spec 状态机 + decision fixtures 评测
- **对 HiQ**：实体模型、目录布局、路由哲学、通道分级几乎直接继承并精简

### 10. T-Tools — 阶段化交付

- Decision → tech-research → PRD → design → task(phase) → run → demo → accept → publish
- 可选 check 阶段；强制人校准
- **对 HiQ**：`hiq-feature` Standard/Heavy 的 phase 切片；demo/accept 作为验收形态

## 合成决策（HiQ 取舍）

| 决策 | 选择 | 理由 |
|------|------|------|
| 中心模型 | 软件实体（CodeStable） | 跨年项目需要可检索记忆 |
| 流程重量 | 风险自适应（Aegis + CodeStable lanes） | 避免 Superpowers 散装与 OMO 过重 |
| 架构阶段 | architecture-copilot | 写码前约束质量最高 |
| 变更形态 | Rasen-like change folder | propose/apply/archive 可审计 |
| 外部学习 | Assay 语义内化到 hiq-study | 不依赖 Assay CLI |
| 个人层 | COMPASS 精简 4 件套 | hiq-profile / handoff / clarify / skill 进化 |
| 专家层 | 路由 hint 而非角色 cast | 降低表演成本 |
| 上下文 | Headroom 原则 + 文件落盘 | 防 context window 爆 |
| 安全 | keysmith 的 dry-run/backup only | 不碰 jailbreak 指令 |
| Trellis | session/continue/finish/spec/check/break-loop | 会话与规范 OS |
| do-it | router/grill/slice/fix-loop/verify/interface/… | 定级与工程门禁 |

## 定位（已修正）

HiQ **完全替代** Trellis / do-it / Assay / CodeStable 等方法包作为日常开发 OS。  
来源项目只提供**机制精华**，运行时不再并行委派。

## 故意比源项目更薄的地方

1. 不维护 30+ 兼容旧 skill 名。
2. 不内置多宿主 plugin 矩阵（先服务 LiveAgent / Codex skill 形态）。
3. 不强制 TDD；默认 off，高风险可开。
4. 不自动多 agent 编排；需要时 `hiq-delegate`，写清 owner 与返回契约。
5. 不捆绑外部 CLI 守护进程；纯 skill + `.hiq/` 文件协议。
