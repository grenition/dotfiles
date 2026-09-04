#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required: https://brew.sh" >&2
  exit 1
fi

while IFS=: read -r pkg bin; do
  [[ -z "$pkg" || "$pkg" == \#* ]] && continue
  bin="${bin:-$pkg}"
  if command -v "$bin" >/dev/null 2>&1; then
    echo "$bin already on PATH, skipping $pkg"
  else
    brew install "$pkg"
  fi
done < "$REPO_DIR/deps.txt"

if command -v gitlab-ci-ls >/dev/null 2>&1; then
  echo "gitlab-ci-ls already on PATH, skipping"
else
  brew install alesbrelih/gitlab-ci-ls/gitlab-ci-ls
fi

# zsh completion plugins (no binaries; checked by their installed files).
BREW_PREFIX="$(brew --prefix)"
for pkg_path in \
  "zsh-autocomplete:share/zsh-autocomplete/zsh-autocomplete.plugin.zsh" \
  "zsh-autosuggestions:share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "zsh-completions:share/zsh-completions"
do
  pkg="${pkg_path%%:*}"
  path_="$BREW_PREFIX/${pkg_path#*:}"
  if [ -e "$path_" ]; then
    echo "$pkg already installed, skipping"
  else
    brew install "$pkg"
  fi
done

# macOS-only extras, not in deps.txt since they have no common cross-platform name.
# Uncomment if you work on .NET projects (needed for the C# tooling in config/nvim).
# brew install --cask dotnet-sdk
