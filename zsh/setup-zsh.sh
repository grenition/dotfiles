#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ln -sfn "$DIR/zshrc" "$HOME/.zshrc"
ln -sfn "$DIR/zshenv" "$HOME/.zshenv"

echo "Zsh configuration installed"
