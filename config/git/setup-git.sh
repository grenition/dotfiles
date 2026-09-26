#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.config/git"

ln -sfn "$DIR/ignore" "$HOME/.config/git/ignore"
ln -sfn "$DIR/gitconfig" "$HOME/.config/git/gitconfig"

if ! git config --global --get-all include.path | grep -Fxq "$HOME/.config/git/gitconfig"; then
    git config --global --add include.path "$HOME/.config/git/gitconfig"
fi

echo "Git configuration installed"
