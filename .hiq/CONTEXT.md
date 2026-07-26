# Context — HiQ

## Product

HiQ：替代 Trellis/do-it 的本地 AI 开发 Skill OS。技能在 `plugins/hiq/skills/`，产品仓运行时在 `.hiq/`，代码引擎为 Cleboost/codegraph-rs。

## Users / non-users

- 用户：用 LiveAgent/Codex 等做严肃开发的个人/小团队
- 非目标：不替代 IDE；不做成多 Agent 聊天平台

## Invariants

- 产品仓唯一状态树：`.hiq/`
- 技能前缀：`hiq-*`
- 代码图：必须用 `~/.hiq/bin/codegraph`（codegraph-rs），不用 PATH 上旧包装
- 完成声明需要 evidence

## Glossary

| Term | Meaning |
|------|---------|
| hiq-init | 产品仓初始化（记忆 + session 指针 + codegraph） |
| hiq-install | 宿主 skills + codegraph-rs 安装 |
| session.md | 可恢复 active_change / phase |
| graph/ | 人读模块地图；符号真源在 .codegraph/ |

## Explicit non-goals

- 不捆绑 Headroom 压缩 proxy
- 不复制 ExpertTeam 设计/产品整团
