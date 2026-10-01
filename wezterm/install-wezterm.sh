#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.config/wezterm"

ln -sfn "$DIR/wezterm.lua" "$HOME/.wezterm.lua"
ln -sfn "$DIR/modules" "$HOME/.config/wezterm"

echo "Wezterm configuration installed"
