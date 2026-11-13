#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for app in git vim nvim yazi zsh; do
    bash "$DIR/$app/setup-$app.sh"
done

mkdir -p "$HOME/.config/tmux"
ln -sfn "$DIR/tmux/linux.tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$DIR/tmux/include" "$HOME/.config/tmux/include"
