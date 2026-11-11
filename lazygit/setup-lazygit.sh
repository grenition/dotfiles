#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/lazygit"

mkdir -p "$CONFIG_DIR"
ln -sfn "$DIR/config.yml" "$CONFIG_DIR/config.yml"

echo "Lazygit configuration installed"
