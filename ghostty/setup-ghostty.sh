#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"

mkdir -p "$CONFIG_DIR"
ln -sfn "$DIR/config.ghostty" "$CONFIG_DIR/config.ghostty"

mkdir -p "$CONFIG_DIR/themes"
for theme in "$DIR"/themes/*; do
  ln -sfn "$theme" "$CONFIG_DIR/themes/$(basename "$theme")"
done

echo "Ghostty configuration installed"
