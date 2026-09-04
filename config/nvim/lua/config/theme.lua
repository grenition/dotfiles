local M = {}

local theme_file = vim.fs.joinpath(vim.fn.stdpath("config"), "lua/config/theme_selection.lua")
local selection = { light = "vscode-light", dark = "vscode-dark" }
local last_mode
local selection_stamp

function M.apply_ui_highlights()
  vim.cmd("highlight StatusLine cterm=NONE ctermfg=7 ctermbg=NONE")
  vim.cmd("highlight StatusLineNC cterm=NONE ctermfg=8 ctermbg=NONE")
  vim.cmd("highlight StatusLineMode cterm=bold ctermfg=6 ctermbg=NONE")
  vim.cmd("highlight BufferLineFill cterm=NONE ctermfg=NONE ctermbg=NONE")
  vim.cmd("highlight BufferLineBackground cterm=NONE ctermfg=7 ctermbg=NONE")
  vim.cmd("highlight BufferLineBufferVisible cterm=NONE ctermfg=7 ctermbg=NONE")
  vim.cmd("highlight BufferLineSeparator cterm=NONE ctermfg=8 ctermbg=NONE")

  local is_dark = vim.o.background == "dark"
  local accent = is_dark and "#42B09A" or (vim.g.terminal_color_6 or "#00A7B5")
  local accent_cterm = is_dark and 37 or 6
  local accent_fg = is_dark and "#1F1F1F" or "#FFFFFF"
  for _, group in ipairs({
    "BufferLineTabSelected",
    "BufferLineTabCloseSelected",
    "BufferLineCloseButtonSelected",
    "BufferLineBufferSelected",
    "BufferLineNumbersSelected",
    "BufferLineDiagnosticSelected",
    "BufferLineHintSelected",
    "BufferLineHintDiagnosticSelected",
    "BufferLineInfoSelected",
    "BufferLineInfoDiagnosticSelected",
    "BufferLineWarningSelected",
    "BufferLineWarningDiagnosticSelected",
    "BufferLineErrorSelected",
    "BufferLineErrorDiagnosticSelected",
    "BufferLineModifiedSelected",
    "BufferLineDuplicateSelected",
    "BufferLinePickSelected",
    "BufferLineSeparatorSelected",
    "BufferLineIndicatorSelected",
  }) do
    local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
    highlight.default = nil
    highlight.bg = accent
    highlight.ctermbg = accent_cterm
    highlight.underline = false
    vim.api.nvim_set_hl(0, group, highlight)
  end

  for _, group in ipairs({
    "BufferLineTabSelected",
    "BufferLineTabCloseSelected",
    "BufferLineCloseButtonSelected",
    "BufferLineBufferSelected",
    "BufferLineNumbersSelected",
    "BufferLineModifiedSelected",
    "BufferLineDuplicateSelected",
    "BufferLinePickSelected",
  }) do
    local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
    highlight.default = nil
    highlight.fg = accent_fg
    highlight.ctermfg = 0
    highlight.bold = true
    vim.api.nvim_set_hl(0, group, highlight)
  end

  vim.api.nvim_set_hl(0, "NavigableLink", { underline = true })

  if vim.g.colors_name == "vscode-light" then
    -- Clear overrides from the earlier sidebar treatment. These groups are
    -- intentionally empty in vscode.nvim, so neo-tree inherits the editor UI.
    for _, group in ipairs({
      "NeoTreeNormal",
      "NeoTreeNormalNC",
      "NeoTreeSignColumn",
      "NeoTreeEndOfBuffer",
      "NeoTreeWinSeparator",
      "NeoTreeIndentMarker",
      "NeoTreeExpander",
    }) do
      vim.api.nvim_set_hl(0, group, {})
    end
    vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = "#E5E5E5" })
    vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = "#8E8E90" })
  end
end

function M.apply(name)
  vim.o.termguicolors = name ~= "terminal"
  local ok, err = pcall(vim.cmd.colorscheme, name)
  if not ok then
    vim.notify("Could not load colorscheme " .. name .. ": " .. err, vim.log.levels.ERROR)
    return
  end

  M.apply_ui_highlights()
end

local function selection_file_stamp()
  local stat = vim.uv.fs_stat(theme_file)
  if not stat then
    return nil
  end

  return table.concat({ stat.mtime.sec, stat.mtime.nsec, stat.size }, ":")
end

local function load_selection()
  local ok, saved = pcall(dofile, theme_file)
  if not ok then
    return nil
  end

  local before = vim.deepcopy(selection)
  if type(saved) == "table" then
    selection.light = type(saved.light) == "string" and saved.light or selection.light
    selection.dark = type(saved.dark) == "string" and saved.dark or selection.dark
  elseif type(saved) == "string" then
    -- One-time compatibility with the old single-theme format.
    selection.light = saved
    selection.dark = saved
  else
    return nil
  end

  -- Split the old background-dependent vscode entry into deterministic
  -- colorscheme aliases. This keeps existing preference files compatible.
  if selection.light == "vscode" then
    selection.light = "vscode-light"
  end
  if selection.dark == "vscode" then
    selection.dark = "vscode-dark"
  end

  return before.light ~= selection.light or before.dark ~= selection.dark
end

local function reload_selection_if_changed()
  local stamp = selection_file_stamp()
  if stamp == selection_stamp then
    return false
  end

  -- A second Neovim instance may be writing at this exact moment.  Keep the
  -- old stamp on a parse failure, so the next tick retries instead of losing
  -- the change.
  local changed = load_selection()
  if changed == nil then
    return false
  end

  selection_stamp = stamp
  return changed
end

local function persist_selection()
  vim.fn.writefile({
    "-- Updated by <Space>ud and <Space>un. Keep this file in the dotfiles repository.",
    "return {",
    string.format("  light = %q,", selection.light),
    string.format("  dark = %q,", selection.dark),
    "}",
  }, theme_file)
  package.loaded["config.theme_selection"] = vim.deepcopy(selection)
  selection_stamp = selection_file_stamp()
end

function M.is_dark()
  if vim.fn.has("mac") == 1 and vim.fn.executable("defaults") == 1 then
    local result = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
    -- macOS omits AppleInterfaceStyle entirely in Light mode.
    return vim.v.shell_error == 0 and result:lower():find("dark", 1, true) ~= nil
  end
  return vim.o.background == "dark"
end

function M.current_mode()
  return M.is_dark() and "dark" or "light"
end

function M.refresh()
  local selection_changed = reload_selection_if_changed()
  local mode = M.current_mode()
  if mode == last_mode and not selection_changed then
    return
  end
  last_mode = mode
  vim.o.background = mode
  M.apply(selection[mode])
end

function M.set(mode, name)
  selection[mode] = name
  persist_selection()
  vim.notify(string.format("Saved %s theme: %s", mode, name), vim.log.levels.INFO)
  if M.current_mode() == mode then
    last_mode = mode
    vim.o.background = mode
    M.apply(name)
  end
end

function M.pick(mode)
  require("fzf-lua").colorschemes({
    live_preview = true,
    -- The raw entry chooses its variant from the ambient 'background' value,
    -- which makes its preview ambiguous. Show only the explicit variants.
    ignore_patterns = { "^vscode$" },
    actions = {
      ["enter"] = function(selected)
        if selected[1] then
          -- fzf-lua restores its original preview when the picker closes.
          -- Reapply on the next event-loop tick so the accepted preview wins.
          local accepted = selected[1]
          vim.schedule(function()
            M.set(mode, accepted)
          end)
        end
      end,
    },
  })
end

local group = vim.api.nvim_create_augroup("terminal_ui_theme", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function()
    -- bufferline also refreshes generated groups on ColorScheme. Apply our
    -- final UI treatment after every plugin has handled the event.
    vim.schedule(M.apply_ui_highlights)
  end,
})

vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
  group = group,
  callback = M.refresh,
})

load_selection()
selection_stamp = selection_file_stamp()
-- Apply the initial theme before plugins snapshot colors into generated
-- highlight groups. In particular, indent-blankline copies IblIndent during
-- setup and otherwise can retain Normal's bright foreground until the next
-- manual :colorscheme command.
M.refresh()

-- macOS does not expose appearance-change notifications to a terminal app.
-- One low-frequency timer also picks up selections saved by another instance.
local refresh_timer = vim.uv.new_timer()
refresh_timer:start(5000, 5000, vim.schedule_wrap(M.refresh))
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = function()
    refresh_timer:stop()
    refresh_timer:close()
  end,
})

return M
