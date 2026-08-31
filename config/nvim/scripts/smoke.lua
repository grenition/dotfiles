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
  vim.api.nvim_get_hl(0, { name = "NeoTreeNormal", link = false }).bg == nil,
  "VS Code Light+ neo-tree background must match the editor"
)
assert(
  next(vim.api.nvim_get_hl(0, { name = "NeoTreeIndentMarker", link = false })) == nil,
  "VS Code Light+ neo-tree indentation must use the default style"
)
assert(
  vim.api.nvim_get_hl(0, { name = "NeoTreeCursorLine", link = false }).bg == 0xE5E5E5,
  "VS Code Light+ neo-tree cursor line did not reset"
)
assert(
  vim.api.nvim_get_hl(0, { name = "NeoTreeDirectoryIcon", link = false }).fg == 0x8E8E90,
  "VS Code Light+ neo-tree directory icon color did not load"
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
