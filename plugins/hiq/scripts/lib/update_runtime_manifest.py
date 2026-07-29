#!/usr/bin/env python3
"""Refresh .hiq/runtime-manifest.json after a project-init run."""

from __future__ import annotations

import json
import os
import pathlib
import re
import subprocess
import sys
from datetime import datetime
from typing import Any


def run_capture(args: list[str], *, env: dict[str, str] | None = None) -> tuple[int, str]:
    proc = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, env=env)
    return proc.returncode, proc.stdout or ""


def parse_status_metrics(output: str) -> dict[str, int | str]:
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


def status_from_json(script_path: pathlib.Path, root: pathlib.Path) -> tuple[str, dict[str, Any] | None]:
    if not script_path.exists():
        return "missing", None
    rc, output = run_capture(["bash", str(script_path), str(root), "--json"])
    try:
        parsed = json.loads(output)
    except json.JSONDecodeError:
        return ("error" if rc != 0 else "partial"), None
    pointer = parsed.get("pointerStatus")
    if rc == 0 and pointer == "ok":
        return "ok", parsed
    return "partial", parsed


def doctor_from_json(script_path: pathlib.Path, root: pathlib.Path, env: dict[str, str]) -> tuple[str, dict[str, Any] | None]:
    if not script_path.exists():
        return "missing", None
    rc, output = run_capture(["bash", str(script_path), str(root), "--json"], env=env)
    try:
        parsed = json.loads(output)
    except json.JSONDecodeError:
        return ("error" if rc != 0 else "partial"), None
    overall = parsed.get("overall")
    if rc == 0 and overall == "ok":
        return "ok", parsed
    return "partial", parsed


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

    _, cg_status_output = run_capture([bin_path, "status", "--path", str(root)])
    metrics = parse_status_metrics(cg_status_output)
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

    hiq_home = pathlib.Path(os.environ.get("HIQ_HOME_DIR") or (pathlib.Path.home() / ".hiq"))
    scripts_dir = hiq_home / "scripts"
    status_script = scripts_dir / "hiq-status.sh"
    doctor_script = scripts_dir / "hiq-doctor.sh"
    hook_script = scripts_dir / "hiq-hook.sh"
    runtime_env = dict(os.environ)
    runtime_env.setdefault("HIQ_HOME_DIR", str(hiq_home))

    hiq_status, status_json = status_from_json(status_script, root)
    hiq_doctor, doctor_json = doctor_from_json(doctor_script, root, runtime_env)
    hiq_hook = "ok" if hook_script.exists() else "missing"

    session_pointer: dict[str, Any] | None = None
    if status_json:
        session_pointer = {
            "entry_skill": status_json.get("entrySkill"),
            "entry_mode": status_json.get("entryMode"),
            "auto_status": status_json.get("autoStatus"),
            "owner_skill": status_json.get("ownerSkill"),
            "next_skill": status_json.get("nextSkill"),
            "goal_path": status_json.get("goalPath"),
            "host_automation_level": status_json.get("hostAutomationLevel"),
            "pointer_status": status_json.get("pointerStatus"),
        }

    runtime_state = {
        "hiq_status": hiq_status,
        "hiq_doctor": hiq_doctor,
        "hiq_hook": hiq_hook,
        "updated_at": datetime.now().astimezone().strftime("%Y-%m-%dT%H:%M:%S%z"),
    }
    if doctor_json:
        runtime_state["doctor_overall"] = doctor_json.get("overall")
        runtime_state["doctor_state"] = doctor_json.get("stateOverall")

    manifest["framework"] = "hiq"
    manifest["schema"] = int(manifest.get("schema", 2) or 2)
    manifest["mode"] = "refresh"
    manifest.setdefault("created_at", datetime.now().strftime("%Y-%m-%d"))
    manifest["updated_at"] = datetime.now().astimezone().strftime("%Y-%m-%dT%H:%M:%S%z")
    manifest["codegraph"] = codegraph
    manifest["runtime_state"] = runtime_state
    if session_pointer:
        manifest["session_pointer"] = session_pointer

    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(
        f"manifest={manifest_path} files={metrics['files']} nodes={metrics['nodes']} edges={metrics['edges']} hiq_status={hiq_status} hiq_doctor={hiq_doctor}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
