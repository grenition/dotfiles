local modes = {
  n = "NORMAL",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  c = "COMMAND",
  R = "REPLACE",
  t = "TERMINAL",
}

vim.o.laststatus = 3

function _G.clean_statusline()
  local mode = modes[vim.api.nvim_get_mode().mode] or "NORMAL"
  local branch = vim.b.gitsigns_head and ("   " .. vim.b.gitsigns_head) or ""
  local filename = vim.fn.expand("%:.")
  if filename == "" then
    filename = "[No Name]"
  end
  local modified = vim.bo.modified and " [+]" or ""
  local readonly = vim.bo.readonly and " [RO]" or ""

  return string.format(
    " %%#StatusLineMode#%s%%#StatusLine#%s  %%<%s%s%s %%=%%y  %%l:%%c ",
    mode,
    branch,
    filename,
    modified,
    readonly
  )
end

vim.o.statusline = "%!v:lua.clean_statusline()"
