#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required: https://brew.sh" >&2
  exit 1
fi

while IFS=: read -r pkg spec; do
  [[ -z "$pkg" || "$pkg" == \#* ]] && continue
  spec="${spec:-$pkg}"
  if [[ "$spec" == @* ]]; then
    present() { [ -e "$(brew --prefix)/${1#@}" ]; }
  else
    present() { command -v "$1" >/dev/null 2>&1; }
  fi
  if present "$spec"; then
    echo "$pkg already installed, skipping"
  else
    brew install "$pkg"
  fi
done < "$REPO_DIR/deps.txt"

if command -v gitlab-ci-ls >/dev/null 2>&1; then
  echo "gitlab-ci-ls already on PATH, skipping"
else
  brew install alesbrelih/gitlab-ci-ls/gitlab-ci-ls
fi

# macOS-only extras, not in deps.txt since they have no common cross-platform name.
# Uncomment if you work on .NET projects (needed for the C# tooling in config/nvim).
# brew install --cask dotnet-sdk
