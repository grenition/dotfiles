#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${CODEX_HOME:-$HOME/.codex}"

sh "$DIR/scripts/link-skills.sh" "$HOME/.agents/skills"
sh "$DIR/scripts/link-agents-md.sh" "$CONFIG_DIR/AGENTS.md"

if [[ "${INSTALL_NPM_SKILLS:-}" == "true" ]]; then
    sh "$DIR/scripts/install-npm-skills.sh" --agent codex
fi
