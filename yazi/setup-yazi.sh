#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/yazi"

mkdir -p "$CONFIG_DIR"

ln -sfn "$DIR/yazi.toml" "$CONFIG_DIR/yazi.toml"
ln -sfn "$DIR/keymap.toml" "$CONFIG_DIR/keymap.toml"
ln -sfn "$DIR/theme.toml" "$CONFIG_DIR/theme.toml"

echo "Yazi configuration installed"
