#!/usr/bin/env python3
"""Portable MCP wiring for HiQ-managed codegraph-rs.

No machine-absolute paths. Project-relative launchers + PATH-based command
so the same repo migrates across machines/OSes.
"""
from __future__ import annotations

import json
import os
import stat
import sys
from pathlib import Path

# Relative to project root — portable across machines
REL_LAUNCHER_UNIX = ".hiq/tools/codegraph"
REL_LAUNCHER_WIN = ".hiq/tools/codegraph.cmd"
# Prefer bare name when host resolves PATH (~/.hiq/bin added by hiq-install docs)
PATH_CMD = "codegraph"


def write_project_launchers(root: Path) -> None:
    """Write project-relative wrappers that resolve the managed binary at runtime."""
    tools = root / ".hiq" / "tools"
    tools.mkdir(parents=True, exist_ok=True)

    unix = tools / "codegraph"
    unix.write_text(
        """#!/usr/bin/env sh
# Portable HiQ codegraph launcher (project-relative). Resolves managed binary at runtime.
set -eu
if [ -n "${HIQ_CODEGRAPH:-}" ] && [ -x "${HIQ_CODEGRAPH}" ]; then
  exec "${HIQ_CODEGRAPH}" "$@"
fi
if [ -x "${HOME}/.hiq/bin/codegraph" ]; then
  exec "${HOME}/.hiq/bin/codegraph" "$@"
fi
# HiQ repo layout (framework developers)
ROOT="$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)"
if [ -x "${ROOT}/plugins/hiq/bin/codegraph" ]; then
  exec "${ROOT}/plugins/hiq/bin/codegraph" "$@"
fi
if [ -x "${ROOT}/plugins/hiq/scripts/codegraph.sh" ]; then
  exec sh "${ROOT}/plugins/hiq/scripts/codegraph.sh" "$@"
fi
echo "hiq-codegraph: binary not found. Run hiq-install / install-codegraph on this machine." >&2
exit 127
""",
        encoding="utf-8",
    )
    unix.chmod(unix.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    win = tools / "codegraph.cmd"
    win.write_text(
        """@echo off
setlocal
REM Portable HiQ codegraph launcher (project-relative) for Windows cmd.
if defined HIQ_CODEGRAPH if exist "%HIQ_CODEGRAPH%" (
  "%HIQ_CODEGRAPH%" %*
  exit /b %ERRORLEVEL%
)
if exist "%USERPROFILE%\\.hiq\\bin\\codegraph.exe" (
  "%USERPROFILE%\\.hiq\\bin\\codegraph.exe" %*
  exit /b %ERRORLEVEL%
)
if exist "%USERPROFILE%\\.hiq\\bin\\codegraph" (
  "%USERPROFILE%\\.hiq\\bin\\codegraph" %*
  exit /b %ERRORLEVEL%
)
echo hiq-codegraph: binary not found. Run hiq-install / install-codegraph.cmd on this machine.
exit /b 127
""",
        encoding="utf-8",
    )
    print(f"configure-mcp: wrote {unix}")
    print(f"configure-mcp: wrote {win}")


def mcp_entry() -> dict:
    """PATH-name entry. Prefer project-relative when an older codegraph may shadow PATH."""
    return {
        "command": PATH_CMD,
        "args": ["serve", "--mcp"],
    }


def mcp_entry_project_relative(windows: bool = False) -> dict:
    """Preferred portable entry: project-relative launcher (no machine path).

    Resolves ~/.hiq/bin at runtime so a system/older codegraph on PATH
    (e.g. 0.9.x under ~/.local/bin) cannot hijack MCP.
    """
    cmd = REL_LAUNCHER_WIN.replace("\\", "/") if windows else REL_LAUNCHER_UNIX
    return {
        "command": cmd,
        "args": ["serve", "--mcp"],
    }


def write_codex() -> None:
    codex = Path.home() / ".codex"
    if not codex.is_dir():
        print("configure-mcp: skip codex (no ~/.codex)")
        return
    cfg = codex / "config.toml"
    text = cfg.read_text(encoding="utf-8") if cfg.exists() else ""
    # Portable: sh + $HOME/.hiq/bin (not /Users/...), avoids PATH shadow by 0.9.x
    block = (
        "\n[mcp_servers.codegraph]\n"
        'command = "sh"\n'
        'args = ["-c", "exec \\"$HOME/.hiq/bin/codegraph\\" serve --mcp"]\n'
    )
    if "[mcp_servers.codegraph]" in text:
        lines = text.splitlines(keepends=True)
        out = []
        skip = False
        for line in lines:
            stripped = line.strip()
            if stripped.startswith("[mcp_servers.codegraph]"):
                skip = True
                continue
            if skip:
                if stripped.startswith("[") and not stripped.startswith(
                    "[mcp_servers.codegraph]"
                ):
                    skip = False
                    out.append(line)
                continue
            out.append(line)
        text = "".join(out).rstrip() + "\n" + block.lstrip()
    else:
        text = text.rstrip() + "\n" + block
    cfg.parent.mkdir(parents=True, exist_ok=True)
    cfg.write_text(text if text.endswith("\n") else text + "\n", encoding="utf-8")
    print(f"configure-mcp: updated {cfg} (portable PATH command)")


def write_json_mcp(path: Path) -> None:
    data: dict = {}
    if path.exists():
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except Exception:
            data = {}
    # Prefer project-relative launcher for repo-local configs (migrates with repo)
    entry = mcp_entry_project_relative(windows=False)
    # Also document windows launcher in a comment field is invalid JSON — dual keys not needed
    # Hosts on Windows can use .cmd via codegraph on PATH after install
    if "mcp_servers" in data and "mcpServers" not in data:
        servers = data.get("mcp_servers") or {}
        servers["codegraph"] = entry
        data["mcp_servers"] = servers
    else:
        servers = data.get("mcpServers") or {}
        servers["codegraph"] = entry
        data["mcpServers"] = servers
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"configure-mcp: updated {path}")


def write_liveagent_snippet(root: Path) -> None:
    graph = root / ".hiq" / "graph"
    graph.mkdir(parents=True, exist_ok=True)
    # Prefer project-relative launcher: avoids PATH shadowing by older codegraph (0.9.x).
    # Host must set cwd to the open workspace root when applying (not stored as abs in repo).
    payload = {
        "id": "codegraph",
        "enabled": True,
        "transport": "stdio",
        "command": REL_LAUNCHER_UNIX,
        "args": ["serve", "--mcp"],
        "timeoutMs": 30000,
        "hiq_portable": True,
        "hiq_note": (
            "command is project-relative; McpManager must set cwd to this workspace root. "
            "Do not use bare PATH 'codegraph' if ~/.local/bin has an older install. "
            "If host rejects non-ASCII cwd, use an ASCII symlink to the project as cwd."
        ),
        "hiq_command_windows": REL_LAUNCHER_WIN.replace("\\", "/"),
        "hiq_alt_command_path": PATH_CMD,
        "hiq_require_cwd": True,
    }
    p = graph / "mcp-liveagent.json"
    p.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"configure-mcp: wrote {p}")
    hiq = Path.home() / ".hiq"
    hiq.mkdir(parents=True, exist_ok=True)
    # global template also portable (relative launcher; host supplies cwd)
    (hiq / "mcp-codegraph.json").write_text(
        json.dumps(
            {
                "id": "codegraph",
                "enabled": True,
                "transport": "stdio",
                "command": REL_LAUNCHER_UNIX,
                "args": ["serve", "--mcp"],
                "timeoutMs": 30000,
                "hiq_portable": True,
                "hiq_require_cwd": True,
                "hiq_command_windows": REL_LAUNCHER_WIN.replace("\\", "/"),
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"configure-mcp: wrote {hiq / 'mcp-codegraph.json'}")


def write_path_hint(root: Path) -> None:
    """Document PATH setup without hardcoding machine paths."""
    p = root / ".hiq" / "graph" / "PATH.md"
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(
        """# Codegraph PATH (portable)

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
%USERPROFILE%\\.hiq\\bin
```

## LiveAgent apply

- `command`: `.hiq/tools/codegraph` (no abs path)
- `args`: `["serve", "--mcp"]` (no `--path /abs/...`; default = cwd)
- `cwd`: set by host to **this workspace root** at apply time (not committed)
- If the host rejects non-ASCII cwd paths, use an ASCII symlink to the project
""",
        encoding="utf-8",
    )
    print(f"configure-mcp: wrote {p}")


def main(argv: list[str]) -> int:
    # argv: [script, project-root]  (binary path optional and IGNORED for portability)
    if len(argv) < 2:
        print("usage: codegraph_mcp.py <project-root> [ignored-binary]", file=sys.stderr)
        return 2
    root = Path(argv[1]).resolve()
    print(f"configure-mcp: root={root} (portable mode, no absolute binary paths)")
    write_project_launchers(root)
    write_codex()
    write_json_mcp(root / ".cursor" / "mcp.json")
    write_json_mcp(root / ".mcp.json")
    write_liveagent_snippet(root)
    write_path_hint(root)
    print("configure-mcp: done (portable)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
