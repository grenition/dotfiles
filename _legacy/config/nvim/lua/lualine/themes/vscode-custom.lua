-- Palette-derived variant of the lualine theme vscode.nvim ships. The
-- shipped light branch paints normal mode magenta, so this replacement
-- sources every color from require("vscode.colors").get_colors() and
-- anchors normal mode on vscBlueGreen -- the palette entry behind tmux
-- colour6 / ghostty palette 6 in both appearances.
local c = require("vscode.colors").get_colors()
local dark = vim.o.background == "dark"
local bg = dark and c.vscLeftDark or c.vscLeftLight -- statusbar base
local bg2 = c.vscLeftMid -- b-section
local fg = c.vscFront
local accent = c.vscBlueGreen -- tmux colour6
local muted = c.vscLineNumber

local theme = {}
for mode, color in pairs({
  normal = accent,
  insert = c.vscYellow,
  visual = c.vscOrange,
  replace = c.vscRed,
  command = c.vscAccentBlue,
  terminal = accent,
}) do
  theme[mode] = {
    a = { fg = c.vscBack, bg = color, bold = true },
    b = { fg = color, bg = bg2 },
  }
end
-- Only normal mode carries a 'c' section, matching the shipped theme's shape.
theme.normal.c = { fg = fg, bg = bg }

theme.inactive = {
  a = { fg = fg, bg = bg, bold = true },
  b = { fg = muted, bg = bg },
  c = { fg = muted, bg = bg },
}

return theme
