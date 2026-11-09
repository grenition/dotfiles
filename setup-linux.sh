#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for app in git vim nvim yazi zsh; do
    bash "$DIR/$app/setup-$app.sh"
done

mkdir -p "$HOME/.config/tmux"
ln -sfn "$DIR/tmux/linux.conf" "$HOME/.tmux.conf"
ln -sfn "$DIR/tmux/keymap.conf" "$HOME/.config/tmux/keymap.conf"
