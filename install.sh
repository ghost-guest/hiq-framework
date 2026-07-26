#!/usr/bin/env bash
# Deprecated user entrypoint. Prefer Agent skill: $hiq-install (host skills).
# Project init is $hiq-init (creates .hiq/ + CodeGraph), not this script.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
echo "NOTE: Host skills → ask agent \$hiq-install. Project init → \$hiq-init." >&2
TARGET=liveagent
PROJECT_DIR=""
APPLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=1; shift ;;
    --target) TARGET="$2"; shift 2 ;;
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    -h|--help)
      echo "Deprecated. Use skill hiq-install via your agent."
      echo "Compat: $0 --target liveagent|codex|claude|project [--project-dir P] [--apply]"
      exit 0
      ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done
exec "$ROOT/plugins/hiq/scripts/install-skills.sh" "$TARGET" "$PROJECT_DIR" "$APPLY"
