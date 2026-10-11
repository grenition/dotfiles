#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ln -sfn "$DIR/zshrc" "$HOME/.zshrc"

echo "Zsh configuration installed"
