#!/bin/sh
set -eu

SKILLS_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/../skills" && pwd)"
TARGET_DIR="${1:?Usage: $0 TARGET_SKILLS_DIR}"

mkdir -p -- "$TARGET_DIR"

for skill in "$SKILLS_DIR"/*; do
    [ -f "$skill/SKILL.md" ] || continue
    target="$TARGET_DIR/${skill##*/}"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        printf 'Path already exists: %s\n' "$target" >&2
        exit 1
    fi

    ln -sfn -- "$skill" "$target"
done
