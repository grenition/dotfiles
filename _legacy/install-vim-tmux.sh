#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/config"

ln -sfn "$SRC/.vimrc" "$HOME/.vimrc"
ln -sfn "$SRC/tmux/tmux.conf" "$HOME/.tmux.conf"

echo "Symlinked .vimrc and .tmux.conf from $SRC"
