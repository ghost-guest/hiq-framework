# Module Map — HiQ

| Path | Role | Entry | Notes |
|------|------|-------|-------|
| `plugins/hiq/skills/` | 全部 skills | `hiq/SKILL.md`, `hiq-auto/SKILL.md` | retained owners + auto wrapper |
| `plugins/hiq/skills/hiq-init/` | 产品仓初始化 | `SKILL.md` | 记忆+session+codegraph |
| `plugins/hiq/skills/hiq-install/` | 宿主安装 | `SKILL.md` | skills+codegraph-rs |
| `plugins/hiq/scripts/` | 脚本 | `init-project.sh`, `install-codegraph.sh`, `codegraph.sh` | Agent 调用 |
| `plugins/hiq/references/` | 铁律/路由 | `iron-laws.md` | 共享 |
| `plugins/hiq/vendor/` | 引擎钉版本 | `codegraph-rs.version` | Cleboost/codegraph-rs |
| `.hiq/` | 本仓工程记忆 | `BOOTSTRAP.md` | 跨 Agent |
| `.codegraph/` | 代码索引 | `db.sqlite` | codegraph-rs |

See: `graph/modules.md`, `graph/edges.md`.
