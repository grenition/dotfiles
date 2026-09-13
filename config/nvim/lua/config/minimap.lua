local M = {}

-- The minimap overlays ~16 columns, so narrower windows keep it hidden.
local min_editor_width = 80

local excluded_filetypes = { "help", "neo-tree", "fzf", "qf" }

-- Session-only state: the minimap is always on at startup.
local enabled = true

local function minimap_open()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.bufname(buf) == "CodeWindow" then
      return true
    end
  end
  return false
end

local function eligible(win)
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].buftype ~= "" then
    return false
  end
  for _, filetype in ipairs(excluded_filetypes) do
    if vim.bo[buf].filetype == filetype then
      return false
    end
  end
  return vim.api.nvim_win_get_width(win) >= min_editor_width
end

function M.apply()
  vim.schedule(function()
    local win = vim.api.nvim_get_current_win()
    -- Judge by the parent editor window when the current window is floating:
    -- hover floats and other previews must not close (and later reopen) the
    -- minimap just because they became current for a moment.
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      win = config.win
      if not win or not vim.api.nvim_win_is_valid(win) then
        return
      end
    end
    local should_open = enabled and eligible(win)
    if should_open and not minimap_open() then
      require("codewindow").open_minimap()
    elseif not should_open and minimap_open() then
      require("codewindow").close_minimap()
    end
  end)
end

function M.toggle()
  enabled = not enabled
  M.apply()
  vim.notify("Minimap " .. (enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("config_minimap", { clear = true })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinScrolled", "WinResized", "VimResized" }, {
    group = group,
    callback = M.apply,
  })
end

return M
