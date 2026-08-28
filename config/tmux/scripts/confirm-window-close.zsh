#!/bin/zsh

emulate -L zsh
setopt errexit nounset pipefail

response="${1:-}"
window_id="${2:-}"

if [[ -z "$window_id" ]]; then
  exit 1
fi

case "$response" in
  y|н)
    tmux kill-window -t "$window_id"
    ;;
esac
