#!/usr/bin/env bash

set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$REPO_DIR/setup/common/vim.sh"
echo "Dotfiles setup done."
