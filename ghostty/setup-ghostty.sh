#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"

mkdir -p "$CONFIG_DIR"
ln -sfn "$DIR/config.ghostty" "$CONFIG_DIR/config.ghostty"

echo "Ghostty configuration installed"
