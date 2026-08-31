assert(vim.bo.filetype == "lua", "Lua filetype detection failed")
assert(vim.fn.maparg("<leader>ff", "n") ~= "", "core keymaps did not load")
assert(vim.fn.exists(":Neotree") == 2, "neo-tree lazy command is missing")
assert(type(require("bufferline").groups.action) == "function", "bufferline group API is missing")

local plugins = require("lazy.core.config").plugins
assert(plugins["nvim-lspconfig"]._.loaded, "LSP config did not load")
assert(plugins["vscode.nvim"]._.loaded, "VS Code theme did not load")

local theme = require("config.theme")
vim.o.background = "light"
theme.apply("vscode")
assert(
  vim.api.nvim_get_hl(0, { name = "NeoTreeNormal", link = false }).bg == 0xF3F3F3,
  "VS Code Light+ neo-tree background did not load"
)

local visiting = {}
local visited = {}

local function visit(name, path)
  if visited[name] or not plugins[name] then
    return
  end
  if visiting[name] then
    error("cyclic plugin dependency: " .. table.concat(path, " -> ") .. " -> " .. name)
  end

  visiting[name] = true
  table.insert(path, name)
  for _, dependency in ipairs(plugins[name].dependencies or {}) do
    visit(dependency, path)
  end
  table.remove(path)
  visiting[name] = nil
  visited[name] = true
end

for name in pairs(plugins) do
  visit(name, {})
end

print("Neovim config: OK")
