#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

cp -f "$REPO_DIR/config/.vimrc" "$HOME/.vimrc"
