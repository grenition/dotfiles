#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/config"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/ghostty"
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
# macOS lazygit reads its config from app-support, not ~/.config (which is only
# used when XDG_CONFIG_HOME is set). State files live there too, so only the
# config file is symlinked.
mkdir -p "$HOME/Library/Application Support/lazygit"

ln -sfn "$SRC/.vimrc" "$HOME/.vimrc"
ln -sfn "$SRC/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$SRC/jetbrains/.ideavimrc" "$HOME/.ideavimrc"
ln -sfn "$SRC/nvim" "$HOME/.config/nvim"
ln -sfn "$SRC/lazygit" "$HOME/.config/lazygit"
ln -sfn "$SRC/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"
ln -sfn "$SRC/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
ln -sfn "$SRC/ghostty/themes" "$HOME/.config/ghostty/themes"
ln -sfn "$SRC/ghostty/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"

ln -sfn "$SRC/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
ln -sfn "$SRC/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"

# zsh config from the dotfiles repo (idempotent). Order matters: keybindings
# bind reset (bindkey -e) must run before completion plugins wrap the widgets.
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"
if ! grep -q 'dotfiles zsh' "$ZSHRC"; then
  printf '\n# dotfiles zsh\nfor f in keybindings completion; do [ -f "%s/zsh/$f.zsh" ] && source "%s/zsh/$f.zsh"; done\n' \
    "$SRC" "$SRC" >> "$ZSHRC"
fi

echo "Symlinked dotfiles from $SRC"
echo "Run ./install-deps-osx.sh to install required tools via Homebrew (see deps.txt)."
