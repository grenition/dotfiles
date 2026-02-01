#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/config"

mkdir -p "$HOME/.config"

ln -sfn "$SRC/.vimrc" "$HOME/.vimrc"
ln -sfn "$SRC/jetbrains/.ideavimrc" "$HOME/.ideavimrc"
ln -sfn "$SRC/nvim" "$HOME/.config/nvim"

echo "Symlinked dotfiles from $SRC"
