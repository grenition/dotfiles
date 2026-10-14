#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.config"

ln -sfn "$DIR/config" "$HOME/.config/nvim"

echo "Nvim configuration installed"
