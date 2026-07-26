#!/usr/bin/env bash
# Dispatcher for agents: hiq-run.sh <task> [args...]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(bash "$SCRIPT_DIR/lib/detect-os.sh" 2>/dev/null || echo unknown)"
TASK="${1:-}"
shift || true

if [[ -z "$TASK" ]]; then
  echo "usage: hiq-run.sh install-codegraph|project-init|configure-mcp|codegraph|status|doctor [...]" >&2
  exit 2
fi

# Windows host with bash (Git Bash) still prefer cmd for Windows-native paths when requested
if [[ "$OS" == "windows" ]]; then
  case "$TASK" in
    install-codegraph) exec cmd.exe /c "$(cygpath -w "$SCRIPT_DIR/install-codegraph.cmd" 2>/dev/null || echo "$SCRIPT_DIR/install-codegraph.cmd")" "$@" ;;
    project-init) exec cmd.exe /c "$(cygpath -w "$SCRIPT_DIR/codegraph-project-init.cmd" 2>/dev/null || echo "$SCRIPT_DIR/codegraph-project-init.cmd")" "$@" ;;
    configure-mcp) exec cmd.exe /c "$(cygpath -w "$SCRIPT_DIR/configure-codegraph-mcp.cmd" 2>/dev/null || echo "$SCRIPT_DIR/configure-codegraph-mcp.cmd")" "$@" ;;
    codegraph) exec cmd.exe /c "$(cygpath -w "$SCRIPT_DIR/codegraph.cmd" 2>/dev/null || echo "$SCRIPT_DIR/codegraph.cmd")" "$@" ;;
    status) exec cmd.exe /c "$(cygpath -w "$SCRIPT_DIR/hiq-status.cmd" 2>/dev/null || echo "$SCRIPT_DIR/hiq-status.cmd")" "$@" ;;
    doctor) exec cmd.exe /c "$(cygpath -w "$SCRIPT_DIR/hiq-doctor.cmd" 2>/dev/null || echo "$SCRIPT_DIR/hiq-doctor.cmd")" "$@" ;;
  esac
fi

case "$TASK" in
  install-codegraph) exec bash "$SCRIPT_DIR/install-codegraph.sh" "$@" ;;
  project-init) exec bash "$SCRIPT_DIR/codegraph-project-init.sh" "$@" ;;
  configure-mcp) exec bash "$SCRIPT_DIR/configure-codegraph-mcp.sh" "$@" ;;
  codegraph) exec bash "$SCRIPT_DIR/codegraph.sh" "$@" ;;
  status) exec bash "$SCRIPT_DIR/hiq-status.sh" "$@" ;;
  doctor) exec bash "$SCRIPT_DIR/hiq-doctor.sh" "$@" ;;
  *) echo "unknown task: $TASK" >&2; exit 2 ;;
esac
