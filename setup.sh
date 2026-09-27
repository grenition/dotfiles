#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

for dir in ./*/; do
  name="$(basename "$dir")"

  [[ "$name" == .* || "$name" == _* ]] && continue

  for script in "$dir"setup*.sh; do
    echo "Running $script"
    bash "$script"
  done
done
