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

# macOS-only extras, not in deps.txt since they have no common cross-platform name.
# Uncomment if you work on .NET projects (needed for the C# tooling in config/nvim).
# brew install --cask dotnet-sdk
