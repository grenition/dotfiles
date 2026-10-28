#!/bin/sh
set -eu

DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
TARGET_FILE="${1:?Usage: $0 TARGET_AGENTS_FILE}"

mkdir -p -- "$(dirname -- "$TARGET_FILE")"
ln -sfn -- "$DIR/AGENTS.md" "$TARGET_FILE"
