# Project Bootstrap — HiQ

> 任意新 Agent / 工具：先读本文件，再读 MEMORY.md、config.yaml 与 session.md。

## One-liner

**HiQ**：唯一 AI 开发 Skill OS。本仓库是 HiQ 框架本体：11 个 retained owner skill + 可选 `hiq-auto` 自动 wrapper；当前已吸收 Comet 中真正有价值的轻 runtime 状态 / status / doctor / eval / skill harness 能力，但不引入第二套框架表面。

## Verify

```bash
test -f plugins/hiq/skills/hiq-grill/SKILL.md
test -x "$HOME/.hiq/bin/codegraph" && "$HOME/.hiq/bin/codegraph" --version
bash plugins/hiq/scripts/hiq-status.sh .
bash plugins/hiq/scripts/hiq-doctor.sh . || true
```

## Read order

1. `.hiq/BOOTSTRAP.md`（本文件）
2. `.hiq/MEMORY.md`
3. `.hiq/config.yaml`
4. `.hiq/session.md`
5. `.hiq/current-change.json`
6. 若 `session.md` 指向 checkpoint：先读对应 `context-checkpoints/<...>.md`
7. 若有 active change：读 `.hiq/changes/<id>/`
8. `.hiq/MAP.md`
9. `.hiq/graph/` + `codegraph status`

## Code intelligence (HiQ-managed)

```bash
export PATH="$HOME/.hiq/bin:$PATH"
codegraph status
codegraph files
codegraph context "<task>"
```

## Runtime probes

```bash
bash "$HOME/.hiq/scripts/hiq-status.sh" .
bash "$HOME/.hiq/scripts/hiq-doctor.sh" .
# Windows
%USERPROFILE%\\.hiq\\scripts\\hiq-status.cmd .
%USERPROFILE%\\.hiq\\scripts\\hiq-doctor.cmd .
```

## Resume Contract

新会话必须能只靠本地文件继续，不依赖旧聊天：
- `BOOTSTRAP.md`
- `MEMORY.md`
- `config.yaml`
- `session.md`
- `current-change.json`
- active change docs
- latest checkpoint

## Compact / Handoff Rule

上下文压力升高时：
1. 先写 `context-checkpoints/<name>-<date>.md`
2. 把路径写进 `.hiq/session.md` 与 `.hiq/current-change.json`
3. 新会话用 `$hiq-session` 继续

## Resume

```text
$hiq-auto
# 或：继续 context-checkpoints/hiq-retained-wave-complete-20260726-1108.md
# 需要手动单车道时，再显式点名 $hiq-session / $hiq-debug / ...
```
