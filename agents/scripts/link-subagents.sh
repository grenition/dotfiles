#!/bin/sh
set -eu

HARNESS="${1:?Usage: $0 HARNESS TARGET_AGENTS_DIR}"
TARGET_DIR="${2:?Usage: $0 HARNESS TARGET_AGENTS_DIR}"
SUBAGENTS_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/../subagents/$HARNESS" && pwd)"

mkdir -p -- "$TARGET_DIR"

for agent_file in "$SUBAGENTS_DIR"/*; do
    [ -f "$agent_file" ] || continue
    target="$TARGET_DIR/${agent_file##*/}"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        printf 'Path already exists: %s\n' "$target" >&2
        exit 1
    fi

    ln -sfn -- "$agent_file" "$target"
done
