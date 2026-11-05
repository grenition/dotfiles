#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPM_DIR="$HOME/.tmux/plugins/tpm"

if [[ ! -x "$TPM_DIR/tpm" ]]; then
  echo "Installing TPM"
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

mkdir -p "$HOME/.config/tmux"

ln -sfn "$DIR/tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$DIR/keymap.conf" "$HOME/.config/tmux/"
ln -sfn "$DIR/meta.keymap.conf" "$HOME/.config/tmux/"
ln -sfn "$DIR/plugins.conf" "$HOME/.config/tmux/"

echo "Tmux configuration installed"
