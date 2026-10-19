
#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/zsh"

mkdir -p "$CONFIG_DIR"
mkdir -p "$HOME/.local/state/zsh"
mkdir -p "$HOME/.cache/zsh"

# Symlink all Zsh configuration files
for file in "$DIR"/*.zsh "$DIR"/zshrc "$DIR"/zshenv; do
    [[ -f "$file" ]] || continue

    target="$CONFIG_DIR/$(basename "$file")"
    ln -sfn "$file" "$target"
done

ln -sfn "$DIR/zshenv" "$CONFIG_DIR/.zshenv"
ln -sfn "$DIR/zshrc" "$CONFIG_DIR/.zshrc"

# Add source directive only if it doesn't exist
add_source() {
    local root_file="$HOME/.$1"
    local source_line="source \"$CONFIG_DIR/$1\""

    touch "$root_file"

    if ! grep -Fxq "$source_line" "$root_file"; then
        printf '\n%s\n' "$source_line" >> "$root_file"
    fi
}

add_source zshrc
add_source zshenv

echo "Zsh configuration installed"
