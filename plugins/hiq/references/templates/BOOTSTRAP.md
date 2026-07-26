# Project Bootstrap

> Any new agent/tool: read this file first.

## One-liner

## Verify

```bash
```

## Read order

1. `.hiq/BOOTSTRAP.md`
2. `.hiq/MEMORY.md`
3. `.hiq/config.yaml`
4. `.hiq/session.md`
5. `.hiq/current-change.json`
6. active `.hiq/changes/<id>/` if any
7. latest `context-checkpoints/<...>.md` if session points to one
8. `.hiq/MAP.md`
9. `.hiq/graph/` + `codegraph status`

## Code intelligence

```bash
codegraph status
codegraph query <symbol>
codegraph files
codegraph context "<task>"
```

## Resume Contract

A new session must be able to continue from local files alone.  
Do not depend on prior chat history if `BOOTSTRAP.md`, `MEMORY.md`, `session.md`, active change docs, and the latest checkpoint exist.

## Compact / Handoff Rule

When context pressure rises, write a checkpoint under `context-checkpoints/` and store its path in `.hiq/session.md` before switching sessions.

## Runtime probes

```bash
bash "$HOME/.hiq/scripts/hiq-status.sh" .
bash "$HOME/.hiq/scripts/hiq-doctor.sh" .
```

## Resume

```text
$hiq-auto
# manual lane override when needed: $hiq-session / $hiq / $hiq-debug / ...
```
