package.loaded["workspace.palette"] = nil
local c = require("workspace.palette")[vim.o.background]
require("mini.base16").setup {
  palette = {
    base00 = c.bg, base01 = c.panel, base02 = c.selection, base03 = c.muted,
    base04 = c.muted, base05 = c.fg, base06 = c.fg, base07 = c.fg,
    base08 = c.error, base09 = c.syntax.string, base0A = c.warning,
    base0B = c.success, base0C = c.syntax.type, base0D = c.accent,
    base0E = c.syntax.control, base0F = c.syntax.string,
  },
}
vim.g.colors_name = "workspace"
vim.g.terminal_color_0 = vim.o.background == "light" and c.fg or c.panel

local highlights = require("workspace.syntax")(c.syntax)
local groups = {
  { { "Normal", "NormalNC", "SignColumn" }, { fg = c.fg, bg = c.bg } },
  { { "LineNr", "LineNrAbove", "LineNrBelow", "FoldColumn" }, { fg = c.muted, bg = c.bg } },
  { { "CursorLine", "CursorColumn", "ColorColumn" }, { bg = c.panel } },
  { { "CursorLineNr" }, { fg = c.fg, bg = c.panel } },
  { { "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "WinBar", "WinBarNC" }, { fg = c.muted, bg = c.panel } },
  { { "TabLineSel" }, { fg = c.accent, bg = c.bg } },
  { { "WinSeparator" }, { fg = c.border, bg = c.bg } },
  { { "SnacksIndent" }, { fg = c.selection } },
  { { "SnacksIndentScope" }, { fg = c.accent } },
  { { "FloatBorder", "FloatTitle" }, { fg = c.muted, bg = c.panel } },
  { { "NormalFloat", "Pmenu", "NeoTreeNormal", "NeoTreeNormalNC" }, { fg = c.fg, bg = c.panel } },
  { { "Visual", "PmenuSel", "PmenuMatchSel", "NeoTreeCursorLine", "SnacksPickerListCursorLine" }, { fg = c.fg, bg = c.selection } },
  { { "Search" }, { fg = c.fg, bg = c.selection } },
  { { "CurSearch", "IncSearch" }, { fg = c.fg, bg = c.selection, underline = true } },
  { { "Directory", "NeoTreeDirectoryName", "NeoTreeDirectoryIcon", "NeoTreeRootName" }, { fg = c.fg } },
  { { "NeoTreeIndentMarker", "NeoTreeExpander" }, { fg = c.border } },
  { { "SnacksPickerBorder", "SnacksPickerInputBorder", "SnacksPickerBoxBorder", "SnacksPickerPreviewBorder" }, { fg = c.border, bg = c.panel } },
  { { "SnacksPickerTitle", "SnacksPickerInputTitle", "SnacksPickerBoxTitle", "SnacksPickerPreviewTitle" }, { fg = c.fg, bg = c.panel } },
  { { "DiagnosticVirtualTextError" }, { fg = c.error } },
  { { "DiagnosticVirtualTextWarn" }, { fg = c.warning } },
  { { "DiagnosticVirtualTextInfo", "DiagnosticVirtualTextHint" }, { fg = c.accent } },
}
for _, group in ipairs(groups) do
  for _, name in ipairs(group[1]) do highlights[name] = group[2] end
end
for name, value in pairs(highlights) do vim.api.nvim_set_hl(0, name, value) end
