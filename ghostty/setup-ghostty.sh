#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"

mkdir -p "$CONFIG_DIR"
ln -sfn "$DIR/config.ghostty" "$CONFIG_DIR/config.ghostty"

mkdir -p "$CONFIG_DIR/themes"
for theme in "$DIR"/themes/*; do
  ln -sfn "$theme" "$CONFIG_DIR/themes/$(basename "$theme")"
done

mkdir -p "$CONFIG_DIR/shaders"
for shader in "$DIR"/shaders/*.glsl; do
  ln -sfn "$shader" "$CONFIG_DIR/shaders/$(basename "$shader")"
done

echo "Ghostty configuration installed"
