#!/usr/bin/env bash
# Install Cleboost/codegraph-rs (macOS / Linux). Windows: use install-codegraph.cmd
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HIQ_PLUGIN="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$HIQ_PLUGIN/vendor/codegraph-rs.version"
REPO="Cleboost/codegraph-rs"
OS="$(bash "$SCRIPT_DIR/lib/detect-os.sh" 2>/dev/null || true)"

if [[ "$OS" == "windows" ]]; then
  echo "install-codegraph: Windows detected — use install-codegraph.cmd" >&2
  if command -v cmd.exe >/dev/null 2>&1; then
    cmd.exe /c "$(cygpath -w "$SCRIPT_DIR/install-codegraph.cmd" 2>/dev/null || echo "$SCRIPT_DIR/install-codegraph.cmd")"
    exit $?
  fi
  exit 1
fi

BIN_NAME="codegraph"
HIQ_HOME_BASE="${HIQ_HOME_DIR:-$HOME/.hiq}"
HIQ_USER_BIN="${HIQ_BIN_DIR:-$HIQ_HOME_BASE/bin}"
HIQ_PLUGIN_BIN="$HIQ_PLUGIN/bin"

PINNED=""
[[ -f "$VERSION_FILE" ]] && PINNED="$(tr -d '[:space:]' <"$VERSION_FILE")"

uname_s="$(uname -s | tr '[:upper:]' '[:lower:]')"
uname_m="$(uname -m)"
case "$uname_s/$uname_m" in
  linux/x86_64|linux/amd64) target="x86_64-unknown-linux-musl" ;;
  linux/aarch64|linux/arm64) target="aarch64-unknown-linux-gnu" ;;
  darwin/x86_64) target="x86_64-apple-darwin" ;;
  darwin/arm64) target="aarch64-apple-darwin" ;;
  *)
    echo "unsupported platform: $uname_s/$uname_m" >&2
    echo "fallback: cargo install --git https://github.com/$REPO codegraph" >&2
    exit 1
    ;;
esac

if [[ -n "$PINNED" ]]; then
  tag="$PINNED"
else
  tag="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)"
fi
[[ -n "$tag" ]] || { echo "could not resolve codegraph-rs tag" >&2; exit 1; }

url="https://github.com/$REPO/releases/download/$tag/codegraph-${target}.tar.gz"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "hiq-codegraph: os=$OS target=$target"
echo "hiq-codegraph: downloading $url"
curl -fsSL "$url" -o "$tmp/cg.tar.gz"
tar -xzf "$tmp/cg.tar.gz" -C "$tmp"
src=""
[[ -f "$tmp/$BIN_NAME" ]] && src="$tmp/$BIN_NAME"
[[ -z "$src" ]] && src="$(find "$tmp" -type f -name "$BIN_NAME" | head -1)"
[[ -n "$src" && -f "$src" ]] || { echo "binary not found in archive" >&2; exit 1; }

install_one() {
  local dest_dir="$1"
  mkdir -p "$dest_dir"
  install -m 0755 "$src" "$dest_dir/$BIN_NAME"
  echo "hiq-codegraph: installed $tag -> $dest_dir/$BIN_NAME"
}
install_one "$HIQ_USER_BIN"
install_one "$HIQ_PLUGIN_BIN"

mkdir -p "$HIQ_PLUGIN/vendor"
echo "$tag" >"$HIQ_PLUGIN/vendor/codegraph-rs.installed"
{
  echo "repo=https://github.com/$REPO"
  echo "tag=$tag"
  echo "target=$target"
  echo "os=$OS"
  echo "user_bin=$HIQ_USER_BIN/$BIN_NAME"
} >"$HIQ_PLUGIN/vendor/codegraph-rs.meta"

ver="$("$HIQ_USER_BIN/$BIN_NAME" --version 2>/dev/null || true)"
echo "hiq-codegraph: ok ${ver:-installed}"
echo "hiq-codegraph: add to PATH (portable configs expect command name 'codegraph'):"
echo "  export PATH=\"\$HOME/.hiq/bin:\$PATH\""
# Ensure user bin is early in this process for subsequent steps
export PATH="$HIQ_USER_BIN:$PATH"
echo "hiq-codegraph: done"
