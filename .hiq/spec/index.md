# Spec index

## Verify

```bash
test -f plugins/hiq/skills/hiq/SKILL.md
test -x "$HOME/.hiq/bin/codegraph" && "$HOME/.hiq/bin/codegraph" status
find plugins/hiq/skills -name SKILL.md | wc -l   # expect 46+
```

## Layers

- skills: `plugins/hiq/skills/hiq-*`
- runtime protocol: `.hiq/**`
- engine: codegraph-rs via `~/.hiq/bin`

## Quality check pointers

- skill 改动后同步 `$hiq-install` 到宿主
- 完成声明前核对 session.md 是否需更新
