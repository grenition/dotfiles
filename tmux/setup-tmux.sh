#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HOME/.config/tmux"

ln -sfn "$DIR/tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$DIR/keymap.conf" "$HOME/.config/tmux/"
ln -sfn "$DIR/meta.keymap.conf" "$HOME/.config/tmux/"

echo "Tmux configuration installed"
