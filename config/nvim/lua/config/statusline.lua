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

local function is_kubernetes_file()
  if vim.bo.filetype ~= "yaml" then
    return false
  end

  local path = vim.api.nvim_buf_get_name(0)
  return path:find("/k8s/", 1, true) ~= nil
    or path:find("/kubernetes/", 1, true) ~= nil
    or path:find("/manifests/", 1, true) ~= nil
    or path:match("%.k8s%.ya?ml$") ~= nil
    or path:match("%.kubernetes%.ya?ml$") ~= nil
end

local function diagnostic_status()
  local counts = vim.diagnostic.count(0)
  local parts = {}

  if is_kubernetes_file() then
    table.insert(parts, "%#DiagnosticInfo#󱃾 K8S%#StatusLine#")
  end

  local levels = {
    { severity = vim.diagnostic.severity.ERROR, icon = "", group = "DiagnosticError" },
    { severity = vim.diagnostic.severity.WARN, icon = "", group = "DiagnosticWarn" },
    { severity = vim.diagnostic.severity.INFO, icon = "", group = "DiagnosticInfo" },
    { severity = vim.diagnostic.severity.HINT, icon = "󰌵", group = "DiagnosticHint" },
  }
  for _, level in ipairs(levels) do
    local count = counts[level.severity] or 0
    if count > 0 then
      table.insert(parts, string.format("%%#%s#%s %d%%#StatusLine#", level.group, level.icon, count))
    end
  end

  return #parts > 0 and table.concat(parts, " ") .. " " or ""
end

local function lsp_status()
  local names = {}

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    table.insert(names, client.name)
  end

  if #names == 0 then
    return ""
  end

  table.sort(names)
  return string.format("%%#DiagnosticInfo# %s%%#StatusLine# ", table.concat(names, ","))
end

function _G.clean_statusline()
  local mode = modes[vim.api.nvim_get_mode().mode] or "NORMAL"
  local branch = vim.b.gitsigns_head and ("   " .. vim.b.gitsigns_head) or ""
  local filename = vim.fn.expand("%:.")
  if filename == "" then
    filename = "[No Name]"
  end
  local modified = vim.bo.modified and " [+]" or ""
  local readonly = vim.bo.readonly and " [RO]" or ""
  local language_tools = lsp_status() .. diagnostic_status()

  return string.format(
    " %%#StatusLineMode#%s%%#StatusLine#%s  %%<%s%s%s %%= %s%%y  %%l:%%c ",
    mode,
    branch,
    filename,
    modified,
    readonly,
    language_tools
  )
end

vim.o.statusline = "%!v:lua.clean_statusline()"
