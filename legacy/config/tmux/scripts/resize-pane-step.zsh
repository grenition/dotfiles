#!/bin/zsh
# Grow or shrink a pane along one axis: vertical when a vertical neighbor
# exists, horizontal otherwise. Shrink is implemented by growing the neighbor
# into the pane because resize-pane does not accept negative adjustments.
# Usage: resize-pane-step.zsh grow|shrink <pane-id> <step>
set -eu

direction=$1
pane=$2
step=$3

eval "$(tmux display -p -t "$pane" 'top=#{pane_top}; bottom=#{pane_bottom}; left=#{pane_left}; right=#{pane_right}; window=#{window_id}; zoomed=#{window_zoomed_flag}')"
[ "$zoomed" = 1 ] && exit 0

above_id=''
above_bottom=-1
below_id=''
below_top=1000000
left_id=''
left_right=-1
right_id=''
right_left=1000000

while read -r id ptop pbottom pleft pright; do
  [ "$id" = "$pane" ] && continue
  x_overlap=$(( pleft <= right && pright >= left ))
  y_overlap=$(( ptop <= bottom && pbottom >= top ))
  if (( x_overlap && pbottom < top && pbottom > above_bottom )); then
    above_id=$id
    above_bottom=$pbottom
  fi
  if (( x_overlap && ptop > bottom && ptop < below_top )); then
    below_id=$id
    below_top=$ptop
  fi
  if (( y_overlap && pright < left && pright > left_right )); then
    left_id=$id
    left_right=$pright
  fi
  if (( y_overlap && pleft > right && pleft < right_left )); then
    right_id=$id
    right_left=$pleft
  fi
done <<EOF
$(tmux list-panes -t "$window" -F '#{pane_id} #{pane_top} #{pane_bottom} #{pane_left} #{pane_right}')
EOF

if [ "$direction" = grow ]; then
  if [ -n "$above_id" ]; then
    tmux resize-pane -t "$pane" -U "$step"
  elif [ -n "$below_id" ]; then
    tmux resize-pane -t "$pane" -D "$step"
  elif [ -n "$left_id" ]; then
    tmux resize-pane -t "$pane" -L "$step"
  elif [ -n "$right_id" ]; then
    tmux resize-pane -t "$pane" -R "$step"
  fi
else
  if [ -n "$above_id" ]; then
    tmux resize-pane -t "$above_id" -D "$step"
  elif [ -n "$below_id" ]; then
    tmux resize-pane -t "$below_id" -U "$step"
  elif [ -n "$left_id" ]; then
    tmux resize-pane -t "$left_id" -R "$step"
  elif [ -n "$right_id" ]; then
    tmux resize-pane -t "$right_id" -L "$step"
  fi
fi
