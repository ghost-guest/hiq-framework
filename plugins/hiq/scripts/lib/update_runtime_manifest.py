#!/usr/bin/env python3
"""Refresh .hiq/runtime-manifest.json after a project-init run."""

from __future__ import annotations

import json
import pathlib
import re
import subprocess
import sys
from datetime import datetime


def run_capture(args: list[str]) -> tuple[int, str]:
    proc = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return proc.returncode, proc.stdout or ""


def parse_status(output: str) -> dict[str, int | str]:
    result: dict[str, int | str] = {
        "status": "initialized",
        "files": 0,
        "nodes": 0,
        "edges": 0,
    }
    for line in output.splitlines():
        stripped = line.strip()
        for key in ("files", "nodes", "edges"):
            match = re.match(rf"^{key}:\s*(\d+)", stripped)
            if match:
                result[key] = int(match.group(1))
    return result


def detect_version(bin_path: str) -> str:
    for args in ([bin_path, "--version"], [bin_path, "version"]):
        rc, output = run_capture(args)
        if rc != 0 or not output.strip():
            continue
        match = re.search(r"(\d+\.\d+\.\d+(?:[-+][^\s]+)?)", output)
        if match:
            return match.group(1)
        return output.strip().splitlines()[0]
    return ""


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: update_runtime_manifest.py <root> <codegraph-bin>", file=sys.stderr)
        return 2

    root = pathlib.Path(sys.argv[1]).resolve()
    bin_path = sys.argv[2]
    manifest_path = root / ".hiq" / "runtime-manifest.json"
    manifest: dict[str, object] = {}
    if manifest_path.exists():
        try:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            manifest = {}

    _, status_output = run_capture([bin_path, "status", "--path", str(root)])
    metrics = parse_status(status_output)
    version = detect_version(bin_path)
    existing_codegraph = manifest.get("codegraph") if isinstance(manifest.get("codegraph"), dict) else {}
    codegraph = dict(existing_codegraph)
    codegraph.update(
        {
            "engine": "Cleboost/codegraph-rs",
            "binary": bin_path,
            "version": version,
            "status": metrics["status"],
            "files": metrics["files"],
            "nodes": metrics["nodes"],
            "edges": metrics["edges"],
        }
    )

    manifest["framework"] = "hiq"
    manifest["schema"] = int(manifest.get("schema", 2) or 2)
    manifest["mode"] = "refresh"
    manifest.setdefault("created_at", datetime.now().strftime("%Y-%m-%d"))
    manifest["updated_at"] = datetime.now().astimezone().strftime("%Y-%m-%dT%H:%M:%S%z")
    manifest["codegraph"] = codegraph

    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(
        f"manifest={manifest_path} files={metrics['files']} nodes={metrics['nodes']} edges={metrics['edges']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
