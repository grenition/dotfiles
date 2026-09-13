local modes = {
  n = "NORMAL",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK",
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

local function go_module()
  local root = vim.fs.root(0, { "go.mod" })
  if not root then
    return ""
  end

  local file = io.open(vim.fs.joinpath(root, "go.mod"), "r")
  if not file then
    return ""
  end

  local module
  for line in file:lines() do
    module = string.match(line, "^module%s+(%S+)")
    if module then
      break
    end
  end
  file:close()
  return module and vim.fs.basename(module) or ""
end

-- Project environment segment: "py:<venv>" or "go:<module>". Cached per
-- buffer on the first statusline evaluation; BufWritePost in autocmds.lua
-- drops the cache so the segment follows project file changes.
local function env_status()
  local segment = vim.b.env_status
  if segment == nil then
    segment = ""
    if vim.bo.filetype == "python" then
      segment = "py:" .. require("config.python").name()
    elseif vim.bo.filetype == "go" then
      segment = "go:" .. go_module()
    end
    vim.b.env_status = segment
  end
  if segment == "" then
    return ""
  end
  return string.format(" %%#DiagnosticInfo#%s%%#StatusLine# ", segment)
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
  local language_tools = env_status() .. lsp_status() .. diagnostic_status()

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
