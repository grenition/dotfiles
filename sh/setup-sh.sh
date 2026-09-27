#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.config"

ln -sfn "$DIR" "$HOME/.config/sh"
ln -sfn "$HOME/.config/sh/bashrc" "$HOME/.bashrc"

echo "Shell configuration installed"
