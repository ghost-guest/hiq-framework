#!/usr/bin/env bash
# Host skill install + bundled codegraph-rs. Agent-run via $hiq-install.
set -euo pipefail

HIQ_HOME="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$HIQ_HOME/skills"
REF="$HIQ_HOME/references"
SCRIPTS="$HIQ_HOME/scripts"
VENDOR="$HIQ_HOME/vendor"
TARGET="${1:-liveagent}"
PROJECT_DIR="${2:-}"
APPLY="${3:-1}"

LIVEAGENT_SKILLS="${LIVEAGENT_SKILLS:-$HOME/.liveagent/skills}"
CODEX_SKILLS="${CODEX_SKILLS:-$HOME/.codex/skills}"
CLAUDE_SKILLS="${CLAUDE_SKILLS:-$HOME/.claude/skills}"
HIQ_USER_HOME="${HIQ_HOME_DIR:-$HOME/.hiq}"

case "$TARGET" in
  liveagent) DEST="$LIVEAGENT_SKILLS" ;;
  codex) DEST="$CODEX_SKILLS" ;;
  claude) DEST="$CLAUDE_SKILLS" ;;
  project)
    if [[ -z "$PROJECT_DIR" ]]; then
      echo "project target needs PROJECT_DIR as arg2" >&2
      exit 1
    fi
    DEST="$PROJECT_DIR/.agents/skills"
    ;;
  *) echo "bad target: $TARGET" >&2; exit 1 ;;
esac

if [[ ! -d "$SRC" ]]; then
  echo "missing skills: $SRC" >&2
  exit 1
fi

echo "hiq_home=$HIQ_HOME"
echo "source=$SRC"
echo "dest=$DEST"
echo "apply=$APPLY"

count=0
for d in "$SRC"/*; do
  [[ -d "$d" ]] || continue
  echo "skill=$(basename "$d")"
  count=$((count + 1))
done

if [[ "$APPLY" != "1" ]]; then
  echo "mode=preview count=$count"
  echo "note=apply=1 also installs Cleboost/codegraph-rs plus hiq-status/hiq-doctor into ~/.hiq/scripts and host helper copies"
  exit 0
fi

mkdir -p "$DEST"
STAMP="$(date +%Y%m%d-%H%M%S)"
for d in "$SRC"/*; do
  [[ -d "$d" ]] || continue
  name="$(basename "$d")"
  if [[ -e "$DEST/$name" ]]; then
    mkdir -p "$DEST/.hiq-backup-$STAMP"
    mv "$DEST/$name" "$DEST/.hiq-backup-$STAMP/$name"
    echo "backup=$name"
  fi
  cp -R "$d" "$DEST/$name"
  echo "installed=$name"
done

if [[ -d "$REF" ]]; then
  rm -rf "$DEST/_hiq-references"
  cp -R "$REF" "$DEST/_hiq-references"
  echo "installed=_hiq-references"
fi

# Shared scripts + vendor pins for agent to call after host install
mkdir -p "$HIQ_USER_HOME/scripts" "$HIQ_USER_HOME/vendor" "$HIQ_USER_HOME/bin"
if [[ -d "$SCRIPTS" ]]; then
  cp -R "$SCRIPTS"/. "$HIQ_USER_HOME/scripts/"
  chmod +x "$HIQ_USER_HOME/scripts"/*.sh 2>/dev/null || true
  echo "installed=$HIQ_USER_HOME/scripts"
fi
if [[ -d "$VENDOR" ]]; then
  cp -R "$VENDOR"/. "$HIQ_USER_HOME/vendor/"
  echo "installed=$HIQ_USER_HOME/vendor"
fi
# Also keep a copy next to host skills for discoverability
rm -rf "$DEST/_hiq-scripts" "$DEST/_hiq-vendor"
cp -R "$SCRIPTS" "$DEST/_hiq-scripts"
cp -R "$VENDOR" "$DEST/_hiq-vendor"
echo "installed=_hiq-scripts _hiq-vendor"

# REQUIRED: install Cleboost/codegraph-rs into HiQ-managed bin
echo "hiq-install: installing bundled codegraph-rs..."
bash "$SCRIPTS/install-codegraph.sh"
# keep user scripts in sync (includes codegraph-project-init / configure-mcp)
cp -f "$SCRIPTS"/*.sh "$HIQ_USER_HOME/scripts/" 2>/dev/null || true
chmod +x "$HIQ_USER_HOME/scripts"/*.sh 2>/dev/null || true

echo "done count=$count stamp=$STAMP dest=$DEST codegraph=$HIQ_USER_HOME/bin/codegraph"
