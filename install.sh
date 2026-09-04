#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/config"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/ghostty"
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"

ln -sfn "$SRC/.vimrc" "$HOME/.vimrc"
ln -sfn "$SRC/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$SRC/jetbrains/.ideavimrc" "$HOME/.ideavimrc"
ln -sfn "$SRC/nvim" "$HOME/.config/nvim"
ln -sfn "$SRC/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
ln -sfn "$SRC/ghostty/themes" "$HOME/.config/ghostty/themes"
ln -sfn "$SRC/ghostty/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"

ln -sfn "$SRC/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
ln -sfn "$SRC/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"

# macOS-style zsh keybindings (idempotent).
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"
if ! grep -q 'zsh/keybindings.zsh' "$ZSHRC"; then
  printf '\n# macOS-style editing keys from the dotfiles repo\n[ -f "%s/zsh/keybindings.zsh" ] && source "%s/zsh/keybindings.zsh"\n' \
    "$SRC" "$SRC" >> "$ZSHRC"
fi

# IDE-style command completion (idempotent).
if ! grep -q 'zsh/completion.zsh' "$ZSHRC"; then
  printf '\n# Command completion from the dotfiles repo\n[ -f "%s/zsh/completion.zsh" ] && source "%s/zsh/completion.zsh"\n' \
    "$SRC" "$SRC" >> "$ZSHRC"
fi

echo "Symlinked dotfiles from $SRC"
echo "Run ./install-deps-osx.sh to install required tools via Homebrew (see deps.txt)."
