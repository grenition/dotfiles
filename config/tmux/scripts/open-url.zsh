#!/bin/zsh

emulate -L zsh
setopt extendedglob nocasematch

url="${1:-}"
line="${2:-}"
x="${3:-0}"

if [[ -z "$url" ]]; then
  pattern="((https?|ftp|file)://[^[:space:]<>\"']+|mailto:[^[:space:]<>\"']+|www\\.[^[:space:]<>\"']+)"
  rest="$line"
  offset=0

  while [[ -n "$rest" && "$rest" =~ "$pattern" ]]; do
    start=$((offset + MBEGIN - 1))
    end=$((offset + MEND))
    if (( x >= start && x < end )); then
      url="$MATCH"
      break
    fi
    offset=$end
    rest="${line[$((offset + 1)),-1]}"
  done
fi

[[ -n "$url" ]] || exit 1
url=${url%%[\)\]\}\>.,\;:\!\?\"\x27]##}
[[ "$url" == www.* ]] && url="https://$url"
/usr/bin/open -- "$url"
