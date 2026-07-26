#!/usr/bin/env python3
"""Resolve HiQ-managed codegraph-rs binary path (cross-platform)."""
from __future__ import annotations

import os
import platform
import sys
from pathlib import Path


def candidates() -> list[Path]:
    out: list[Path] = []
    env = os.environ.get("HIQ_CODEGRAPH")
    if env:
        out.append(Path(env))
    home = Path.home()
    hiq_bin = Path(os.environ.get("HIQ_BIN_DIR", home / ".hiq" / "bin"))
    name = "codegraph.exe" if platform.system() == "Windows" else "codegraph"
    out.append(hiq_bin / name)
    # plugin bin next to scripts/lib -> ../../bin
    here = Path(__file__).resolve().parent
    plugin_bin = here.parent.parent / "bin" / name
    out.append(plugin_bin)
    return out


def resolve() -> Path | None:
    for p in candidates():
        try:
            if p.is_file() and os.access(p, os.X_OK):
                return p.resolve()
            # Windows: X_OK may be odd; is_file enough
            if p.is_file() and platform.system() == "Windows":
                return p.resolve()
        except OSError:
            continue
    return None


def main() -> int:
    p = resolve()
    if not p:
        print("", end="")
        return 1
    print(p)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
