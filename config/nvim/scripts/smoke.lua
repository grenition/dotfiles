assert(vim.bo.filetype == "lua", "Lua filetype detection failed")
assert(vim.fn.maparg("<leader>ff", "n") ~= "", "core keymaps did not load")
assert(vim.fn.maparg("<Tab>", "n"):find("BufferLineCycleNext", 1, true), "Tab does not follow bufferline order")
assert(vim.fn.maparg("<S-Tab>", "n"):find("BufferLineCyclePrev", 1, true), "Shift-Tab does not follow bufferline order")
assert(vim.fn.exists(":Neotree") == 2, "neo-tree lazy command is missing")
assert(type(require("bufferline").groups.action) == "function", "bufferline group API is missing")

local unnamed_buffer = vim.api.nvim_create_buf(true, false)
assert(not require("config.buffers").show_in_bufferline(unnamed_buffer), "unnamed buffer is visible in bufferline")
assert(require("config.buffers").show_in_bufferline(0), "named buffer is hidden from bufferline")
vim.api.nvim_buf_delete(unnamed_buffer, { force = true })

local clean_buffer = vim.api.nvim_create_buf(true, false)
require("config.buffers").close(clean_buffer)
assert(not vim.api.nvim_buf_is_valid(clean_buffer), "clean buffer did not close")

local modified_buffer = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_lines(modified_buffer, 0, -1, false, { "unsaved" })
vim.bo[modified_buffer].modified = true
local notify = vim.notify
vim.notify = function() end
require("config.buffers").close(modified_buffer)
vim.notify = notify
assert(vim.api.nvim_buf_is_valid(modified_buffer), "modified buffer was closed without confirmation")
vim.api.nvim_buf_delete(modified_buffer, { force = true })

local plugins = require("lazy.core.config").plugins
assert(plugins["nvim-lspconfig"]._.loaded, "LSP config did not load")
assert(plugins["vscode.nvim"]._.loaded, "VS Code theme did not load")

local theme = require("config.theme")
vim.o.background = "light"
theme.apply("vscode")
local accent = tonumber(vim.g.terminal_color_6:sub(2), 16)
for _, group in ipairs({
  "BufferLineBufferSelected",
  "BufferLineCloseButtonSelected",
  "BufferLineWarningDiagnosticSelected",
  "BufferLineModifiedSelected",
}) do
  assert(vim.api.nvim_get_hl(0, { name = group, link = false }).bg == accent, group .. " lost the active background")
end
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

vim.o.background = "dark"
theme.apply("vscode")
assert(
  vim.api.nvim_get_hl(0, { name = "BufferLineBufferSelected", link = false }).bg == 0x42B09A,
  "VS Code Dark+ active buffer background is too bright"
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
