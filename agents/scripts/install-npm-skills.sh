#!/bin/sh
set -eu

DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

command -v npm > /dev/null 2>&1 || { echo 'npm is required.' >&2; exit 1; }

echo 'Checking skills CLI version...'
current="$(skills --version 2>/dev/null || true)"
latest="$(npm view skills@latest version)"
printf 'skills: %s (latest: %s)\n' "${current:-not installed}" "$latest"

if [ "$current" != "$latest" ]; then
    echo "Installing skills@$latest..."
    npm install --global "skills@$latest"
    printf 'Installed skills %s\n' "$(skills --version)"
else
    echo 'skills CLI is up to date.'
fi

count=0
while read -r repo || [ -n "$repo" ]; do
    case "$repo" in
        ''|\#*) continue ;;
    esac

    printf '\nInstalling/updating skills from %s...\n' "$repo"
    skills add "$repo" --global --skill '*' --yes "$@" < /dev/null
    count=$((count + 1))
done < "$DIR/skills/npm-skills.txt"

echo "Done: $count repositories."
