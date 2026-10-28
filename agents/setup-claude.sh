#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

sh "$DIR/scripts/link-skills.sh" "$CONFIG_DIR/skills"
sh "$DIR/scripts/link-agents-md.sh" "$CONFIG_DIR/CLAUDE.md"

if [[ "${INSTALL_NPM_SKILLS:-}" == "true" ]]; then
    sh "$DIR/scripts/install-npm-skills.sh" --agent claude-code
fi
