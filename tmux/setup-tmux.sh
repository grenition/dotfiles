#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ln -sfn "$DIR/tmux.conf" "$HOME/.tmux.conf"

echo "Tmux configuration installed"
