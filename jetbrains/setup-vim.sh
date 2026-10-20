#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ln -sfn "$DIR/ideavimrc" "$HOME/.ideavimrc"

echo "Jetbrains configuration installed"
