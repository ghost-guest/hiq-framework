# Module edges

| From | To | Kind | Why |
|------|----|------|-----|
| `hiq-auto` | retained 11 | orchestrates | 外层 goal wrapper；每一步选择当前真实 owner |
| `hiq` | `hiq-init` | route | 仓库还没有可靠基线 |
| `hiq` | `hiq-install` | route | 当前问题本质上是宿主安装或 runtime 健康 |
| `hiq` | `hiq-session` | route | 需要先重建会话状态或写 checkpoint |
| `hiq` | `hiq-grill` | route | 目标真实，但范围/验收/方案仍不清楚 |
| `hiq` | `hiq-implement` | route | 已有批准契约，下一步是真实施工 |
| `hiq` | `hiq-debug` | route | 真实 blocker 是根因未明的故障 |
| `hiq` | `hiq-review` | route | 工作基本完成，当前问题是证明是否通过 |
| `hiq` | `hiq-evolve` | route | 任务核心是重构、迁移、性能或加固 |
| `hiq` | `hiq-knowledge` | route | 需要把长期知识沉淀成 durable artifact |
| `hiq` | `hiq-skill` | route | 当前工作是框架治理或 skill 演进 |
| `hiq-init` | `.hiq/` | writes | 建立本地状态和恢复面 |
| `hiq-init` | `.codegraph/` | initializes | 建立代码图索引 |
| `hiq-install` | `~/.hiq/` | syncs | 刷新受管 runtime 副本 |
| `hiq-session` | `.hiq/session.md` | reads/writes | 会话连续性主真源 |
| `hiq-session` | `.hiq/current-change.json` | reads/writes | 机器可读 change 指针 |
| `hiq-grill` | `IMPLEMENT.md` | writes | 形成批准后的施工契约 |
| `hiq-implement` | `evidence.md` | updates | 记录 slice 执行和自查证据 |
| `hiq-debug` | `debug.md` | updates | 记录症状、假设、根因和回归保护 |
| `hiq-review` | `review.md` | updates | 记录 findings、proof 和 verdict |
| `hiq-skill` | host/runtime copies | syncs | 保持 skill 面和已安装副本一致 |
