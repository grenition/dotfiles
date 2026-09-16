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
vim.notify = function(...) end
require("config.buffers").close(modified_buffer)
vim.notify = notify
assert(vim.api.nvim_buf_is_valid(modified_buffer), "modified buffer was closed without confirmation")
vim.api.nvim_buf_delete(modified_buffer, { force = true })

local plugins = require("lazy.core.config").plugins
assert(plugins["nvim-lspconfig"]._.loaded, "LSP config did not load")
assert(plugins["vscode.nvim"]._.loaded, "VS Code theme did not load")
assert(plugins["mason-tool-installer.nvim"]._.loaded, "managed tool installer did not load before VimEnter")
assert(vim.fn.exists(":MasonToolsInstall") == 2, "managed tool install command is missing")
assert(vim.fn.exists(":ToolingInfo") == 2, "managed tool status command is missing")

-- VeryLazy plugins wait for a UI that a headless run never attaches; drive
-- the event once so their loaders run, then verify the statusline came up.
vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
assert(plugins["lualine.nvim"]._.loaded, "lualine statusline did not load")

local tooling = require("config.tooling")
assert(
  vim.deep_equal(plugins["mason-tool-installer.nvim"].opts.ensure_installed, tooling.mason_packages()),
  "installer tools diverged from the managed registry"
)
assert(vim.tbl_contains(tooling.mason_packages(), "kube-linter"), "kube-linter is not managed")
assert(vim.tbl_contains(tooling.mason_packages(), "yamlfmt"), "yamlfmt is not managed")
assert(vim.tbl_contains(tooling.lsp_servers(), "yamlls"), "YAML LSP is not managed")
if vim.fn.executable("go") == 1 then
  assert(vim.tbl_contains(tooling.lsp_servers(), "gopls"), "Go LSP is not enabled when Go is installed")
end

local theme = require("config.theme")
local initial_indent = vim.api.nvim_get_hl(0, { name = "@ibl.indent.char.1", link = false })
local configured_indent = vim.api.nvim_get_hl(0, { name = "IblIndent", link = false })
assert(initial_indent.fg == configured_indent.fg, "indent guides captured a stale startup foreground")
assert(
  initial_indent.fg ~= vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg,
  "indent guides use the bright editor foreground on startup"
)

-- lualine must render with the palette-derived vscode-custom theme. Its
-- loader executes the theme file uncached (dofile) on every ColorScheme, so
-- both aliases re-evaluate get_colors() after a dark/light flip.
local function assert_custom_lualine_theme()
  local custom = require("lualine.utils.loader").load_theme("vscode-custom")
  assert(type(custom) == "table" and type(custom.normal) == "table", "vscode-custom lualine theme did not resolve")
  local accent = require("vscode.colors").get_colors().vscBlueGreen
  assert(custom.normal.a.bg:lower() == accent:lower(), "vscode-custom lualine theme lost the palette accent")
  assert(
    vim.api.nvim_get_hl(0, { name = "lualine_a_normal", link = false }).bg == tonumber(accent:sub(2), 16),
    "lualine did not render with the vscode-custom theme (" .. accent .. ")"
  )
end

theme.apply("vscode-light")
assert(vim.o.background == "light", "VS Code Light+ alias did not select a light background")
assert(vim.g.colors_name == "vscode-light", "VS Code Light+ alias lost its distinct name")
local palette = require("vscode.colors").get_colors()
local accent = tonumber(palette.vscBlueGreen:sub(2), 16)
for _, group in ipairs({
  "BufferLineBufferSelected",
  "BufferLineCloseButtonSelected",
  "BufferLineWarningDiagnosticSelected",
  "BufferLineModifiedSelected",
}) do
  assert(vim.api.nvim_get_hl(0, { name = group, link = false }).bg == accent, group .. " lost the active background")
end
assert(
  vim.api.nvim_get_hl(0, { name = "NeoTreeNormal", link = false }).bg == tonumber(palette.vscLeftLight:sub(2), 16),
  "VS Code Light+ neo-tree background must sit on the sidebar color"
)
assert(
  vim.api.nvim_get_hl(0, { name = "NeoTreeIndentMarker", link = false }).fg
    == tonumber(palette.vscLineNumber:sub(2), 16),
  "VS Code Light+ neo-tree indentation lost its palette guide color"
)
assert(
  vim.api.nvim_get_hl(0, { name = "NeoTreeCursorLine", link = false }).bg == tonumber(palette.vscLeftMid:sub(2), 16),
  "VS Code Light+ neo-tree cursor line lost the selection gray"
)
assert(
  vim.api.nvim_get_hl(0, { name = "NeoTreeDirectoryIcon", link = false }).fg
    == tonumber(palette.vscGitIgnored:sub(2), 16),
  "VS Code Light+ neo-tree directory icon lost its muted gray"
)
assert_custom_lualine_theme()

theme.apply("vscode-dark")
assert(vim.o.background == "dark", "VS Code Dark+ alias did not select a dark background")
assert(vim.g.colors_name == "vscode-dark", "VS Code Dark+ alias lost its distinct name")
local dark_palette = require("vscode.colors").get_colors()
assert(
  vim.api.nvim_get_hl(0, { name = "BufferLineBufferSelected", link = false }).bg
    == tonumber(dark_palette.vscBlueGreen:sub(2), 16),
  "VS Code Dark+ active buffer lost the palette accent"
)
assert(
  vim.api.nvim_get_hl(0, { name = "NeoTreeWinSeparator", link = false }).bg
    == tonumber(dark_palette.vscLeftDark:sub(2), 16),
  "VS Code Dark+ neo-tree separator must stay invisible against the sidebar"
)
assert(
  vim.api.nvim_get_hl(0, { name = "NeoTreeGitModified", link = false }).fg
    == tonumber(dark_palette.vscGitModified:sub(2), 16),
  "VS Code Dark+ neo-tree git status lost its palette color"
)
assert_custom_lualine_theme()

-- Regression: raw same-background colorscheme switches (no theme.apply
-- helper) must not gray out lualine or devicons. terminal and vscode-dark
-- both keep background=dark, and only devicons.setup() registers the
-- ColorScheme restorer that re-creates DevIcon* groups after a switch.
local switch_accent = tonumber(require("vscode.colors").get_colors().vscBlueGreen:sub(2), 16)
vim.cmd.colorscheme("terminal")
vim.cmd.colorscheme("vscode-dark")
vim.wait(100) -- flush the scheduled lualine re-setup
assert(
  vim.api.nvim_get_hl(0, { name = "lualine_a_normal", link = false }).bg == switch_accent,
  "same-background colorscheme switch left lualine without its palette accent"
)
assert(
  vim.api.nvim_get_hl(0, { name = "DevIconLua", link = false }).fg ~= nil,
  "same-background colorscheme switch grayed out devicons"
)
assert(vim.o.termguicolors, "returning from the terminal colorscheme did not restore termguicolors")

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
