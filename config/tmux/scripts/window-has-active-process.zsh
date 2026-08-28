#!/bin/zsh

emulate -L zsh
setopt errexit nounset pipefail

window_id="${1:-}"
if [[ -z "$window_id" ]]; then
  exit 1
fi

default_shell="$(tmux show-option -gv default-shell)"
shell_name="${default_shell:t}"
pane_rows=("${(@f)$(tmux list-panes -t "$window_id" -F '#{pane_pid}:#{pane_current_command}')}" )

for pane_row in "${pane_rows[@]}"; do
  pane_pid="${pane_row%%:*}"
  pane_command="${pane_row#*:}"

  if [[ -n "$pane_command" && "$pane_command" != "$shell_name" ]]; then
    exit 0
  fi

  if /usr/bin/pgrep -P "$pane_pid" >/dev/null 2>&1; then
    exit 0
  fi
done

exit 1
