# Codegraph PATH (portable)

HiQ **never** writes machine-absolute paths into MCP configs.

## Preferred: project-relative launcher

Repo-local MCP (`.mcp.json`, `.cursor/mcp.json`) and LiveAgent snippet use:

```text
.hiq/tools/codegraph       # Unix
.hiq/tools/codegraph.cmd   # Windows cmd
```

These resolve `HIQ_CODEGRAPH` → `~/.hiq/bin/codegraph` at runtime (not random PATH).

## PATH order (critical)

An older install may sit earlier on PATH, e.g.:

```text
~/.local/bin/codegraph  →  codegraph 0.9.x  (WRONG for HiQ)
~/.hiq/bin/codegraph    →  codegraph 1.2.x  (managed)
```

Bare command `codegraph` can therefore spawn the wrong engine. Prefer the
project launcher for MCP. For CLI day-use, put managed bin **first**:

```text
# macOS / Linux (shell profile)
export PATH="$HOME/.hiq/bin:$PATH"

# Windows (user PATH — put first)
%USERPROFILE%\.hiq\bin
```

## LiveAgent apply

- `command`: `.hiq/tools/codegraph` (no abs path)
- `args`: `["serve", "--mcp"]` (no `--path /abs/...`; default = cwd)
- `cwd`: set by host to **this workspace root** at apply time (not committed)
- If the host rejects non-ASCII cwd paths, use an ASCII symlink to the project
