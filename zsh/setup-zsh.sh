#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.config/zsh"

ln -sfn "$DIR/sources" "$HOME/.config/zsh/sources"
ln -sfn "$DIR/zshrc" "$HOME/.zshrc"

echo "Zsh configuration installed"
