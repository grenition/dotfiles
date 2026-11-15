#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/lazygit"

mkdir -p "$CONFIG_DIR"
for config in config dark light; do
  ln -sfn "$DIR/$config.yml" "$CONFIG_DIR/$config.yml"
done

echo "Lazygit configuration installed"
