local M = {}

local theme_file = vim.fs.joinpath(vim.fn.stdpath("config"), "lua/config/theme_selection.lua")
local selection = { light = "terminal", dark = "terminal" }
local last_mode
local selection_stamp

function M.apply_ui_highlights()
  vim.cmd("highlight StatusLine cterm=NONE ctermfg=7 ctermbg=NONE")
  vim.cmd("highlight StatusLineNC cterm=NONE ctermfg=8 ctermbg=NONE")
  vim.cmd("highlight StatusLineMode cterm=bold ctermfg=6 ctermbg=NONE")
  vim.cmd("highlight BufferLineFill cterm=NONE ctermfg=NONE ctermbg=NONE")
  vim.cmd("highlight BufferLineBackground cterm=NONE ctermfg=7 ctermbg=NONE")
  vim.cmd("highlight BufferLineBufferVisible cterm=NONE ctermfg=7 ctermbg=NONE")
  vim.cmd("highlight BufferLineBufferSelected cterm=bold ctermfg=15 ctermbg=NONE")
  vim.cmd("highlight BufferLineSeparator cterm=NONE ctermfg=8 ctermbg=NONE")
  vim.cmd("highlight BufferLineSeparatorSelected cterm=NONE ctermfg=8 ctermbg=NONE")
  vim.cmd("highlight BufferLineIndicatorSelected cterm=NONE ctermfg=6 ctermbg=NONE")
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
  callback = M.apply_ui_highlights,
})

vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
  group = group,
  callback = M.refresh,
})

load_selection()
selection_stamp = selection_file_stamp()
vim.schedule(M.refresh)

-- macOS does not expose appearance-change notifications to a terminal app.
-- Polling this tiny preference keeps the currently open editor in sync too.
local appearance_timer = vim.uv.new_timer()
appearance_timer:start(5000, 5000, vim.schedule_wrap(M.refresh))
local selection_timer = vim.uv.new_timer()
selection_timer:start(1000, 1000, vim.schedule_wrap(M.refresh))
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = function()
    appearance_timer:stop()
    appearance_timer:close()
    selection_timer:stop()
    selection_timer:close()
  end,
})

return M
