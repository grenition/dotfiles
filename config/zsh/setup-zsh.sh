#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.config/zsh"

mkdir -p "$TARGET"

for file in "$DIR"/*.zsh; do
  ln -sfn "$file" "$TARGET/$(basename "$file")"
done

ln -sfn "$DIR/zshrc" "$HOME/.zshrc"

echo "Zsh configuration installed"
