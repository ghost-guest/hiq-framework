# Project Memory — HiQ

## Product

- 完整开发生命周期 skill 框架，可跨 Agent 续作

## Architecture notes

- `$hiq` 根路由；`$hiq-init` 项目初始化；`$hiq-install` 宿主安装
- codegraph-rs 钉版本见 `plugins/hiq/vendor/codegraph-rs.version`

## Conventions

- skill 名 `hiq-*`；运行时 `.hiq/`
- 大输出落盘；不写密钥进 MEMORY

## Active work

- change: （无进行中 change 包；框架本体维护中）
- phase: idle（见 session.md）
- blocker:
- next: 可在真实产品仓跑 `$hiq-init` 验证；或开始第一个 feature change

## Lessons

- init ≠ install：项目初始化与宿主 skill 安装必须分离
- PATH 上可能有旧 codegraph shell，一律以 `~/.hiq/bin/codegraph` 为准

## Agent notes

- codegraph: `~/.hiq/bin/codegraph` v1.2.0
- launcher: `~/.hiq/scripts/codegraph.sh`
- host skills: `~/.liveagent/skills/hiq*`
