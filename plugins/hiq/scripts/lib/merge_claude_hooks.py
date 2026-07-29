#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path


def load_json(path: Path) -> dict:
    if not path.exists():
        return {"hooks": {}}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {"hooks": {}}


def ensure_list(value):
    return value if isinstance(value, list) else []


def filter_existing(entries, needle: str):
    kept = []
    for entry in entries:
        hooks = entry.get("hooks") if isinstance(entry, dict) else None
        if not isinstance(hooks, list):
            kept.append(entry)
            continue
        commands = [h.get("command") for h in hooks if isinstance(h, dict)]
        if any(isinstance(command, str) and needle in command.replace("\\", "/") for command in commands):
            continue
        kept.append(entry)
    return kept


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: merge_claude_hooks.py <hooks-json> <hook-root> <platform>", file=sys.stderr)
        return 2
    hooks_json = Path(sys.argv[1]).expanduser()
    hook_root = Path(sys.argv[2]).expanduser()
    platform = sys.argv[3]

    submit_cmd = str(hook_root / ("user-prompt-submit.cmd" if platform == "windows" else "user-prompt-submit.sh"))
    stop_cmd = str(hook_root / ("stop.cmd" if platform == "windows" else "stop.sh"))

    data = load_json(hooks_json)
    hooks = data.setdefault("hooks", {})
    submit_entries = ensure_list(hooks.get("UserPromptSubmit"))
    stop_entries = ensure_list(hooks.get("Stop"))

    submit_entries = filter_existing(submit_entries, "hiq-auto/user-prompt-submit")
    stop_entries = filter_existing(stop_entries, "hiq-auto/stop")

    submit_entries.append({
        "hooks": [
            {"type": "command", "command": submit_cmd, "timeout": 25}
        ]
    })
    stop_entries.append({
        "hooks": [
            {"type": "command", "command": stop_cmd, "timeout": 25}
        ]
    })

    hooks["UserPromptSubmit"] = submit_entries
    hooks["Stop"] = stop_entries

    hooks_json.parent.mkdir(parents=True, exist_ok=True)
    hooks_json.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"hooks_json={hooks_json} hook_root={hook_root} platform={platform}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
