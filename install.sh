#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/home"

ts=$(date +%Y%m%d_%H%M%S)

backup() {
  local dst="$1"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak.$ts"
  fi
}

mkdir -p "$HOME/.config"

backup "$HOME/.vimrc"
backup "$HOME/.ideavimrc"
backup "$HOME/.config/nvim"

ln -sfn "$SRC/.vimrc" "$HOME/.vimrc"
ln -sfn "$SRC/.ideavimrc" "$HOME/.ideavimrc"
ln -sfn "$SRC/.config/nvim" "$HOME/.config/nvim"

echo "Symlinked dotfiles from $SRC"
