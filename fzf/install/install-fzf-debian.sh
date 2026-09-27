#!/usr/bin/env bash
set -euo pipefail

FZF_DIR="$HOME/.local/share/fzf"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$BIN_DIR"

if [ -d "$FZF_DIR/.git" ]; then
  git -C "$FZF_DIR" pull --ff-only
else
  git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
fi

"$FZF_DIR/install" --bin

ln -sfn "$FZF_DIR/bin/fzf" "$BIN_DIR/fzf"

echo "fzf installed: $("$BIN_DIR/fzf" --version)"
