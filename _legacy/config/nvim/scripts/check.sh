#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v luac >/dev/null 2>&1; then
  while IFS= read -r -d '' file; do
    luac -p "$file"
  done < <(find "$CONFIG_DIR" -type f -name '*.lua' -print0)
fi

if command -v stylua >/dev/null 2>&1; then
  stylua --check "$CONFIG_DIR/init.lua" "$CONFIG_DIR/lua"
fi

RUNTIME_ARTIFACT="$(find "$CONFIG_DIR" -type f \( -name '*.log' -o -name '.nvimlog' \) -print -quit)"
if [[ -n "$RUNTIME_ARTIFACT" ]]; then
  echo "Runtime artifact leaked into the config: $RUNTIME_ARTIFACT" >&2
  exit 1
fi

CHECK_TMP="$(mktemp -d "${TMPDIR:-/tmp}/nvim-config-check.XXXXXX")"
cleanup() {
  rm -rf "$CHECK_TMP"
}
trap cleanup EXIT

XDG_CONFIG_HOME="$(dirname "$CONFIG_DIR")" \
XDG_CACHE_HOME="$CHECK_TMP/cache" \
XDG_STATE_HOME="$CHECK_TMP/state" \
NVIM_CONFIG_CHECK=1 \
  nvim --headless "$CONFIG_DIR/init.lua" \
    "+luafile $CONFIG_DIR/scripts/smoke.lua" \
    "+qa"

XDG_CONFIG_HOME="$(dirname "$CONFIG_DIR")" \
XDG_CACHE_HOME="$CHECK_TMP/cache" \
XDG_STATE_HOME="$CHECK_TMP/state" \
NVIM_CONFIG_CHECK=1 \
  nvim --headless "$CONFIG_DIR" \
    "+sleep 200m" \
    "+lua assert(vim.bo.filetype == 'neo-tree', 'directories must open in neo-tree')" \
    "+qa"
