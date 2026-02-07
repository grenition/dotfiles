#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/config"

ln -sfn "$SRC/.vimrc" "$HOME/.vimrc"

echo "Symlinked .vimrc from $SRC"
