local M = {}

-- The minimap overlays ~16 columns, so narrower windows keep it hidden.
local min_editor_width = 80

local excluded_filetypes = { "help", "neo-tree", "fzf", "qf" }

-- Session-only state: the minimap is always on at startup.
local enabled = true

local function find_minimap()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.bufname(buf) == "CodeWindow" then
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
          return { buf = buf, win = win, parent = vim.api.nvim_win_get_config(win).win }
        end
      end
    end
  end
  return nil
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

local function attach(buf, win, parent)
  if not parent or not vim.api.nvim_win_is_valid(parent) then
    return
  end

  -- The float is created with focusable = false, which blocks mouse focus.
  local conf = vim.api.nvim_win_get_config(win)
  conf.focusable = true
  vim.api.nvim_win_set_config(win, conf)

  local function jump_to_mouse()
    -- 4 buffer lines per minimap row, per codewindow's buf_to_minimap.
    local pos = vim.fn.getmousepos()
    local count = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(parent))
    local line = math.max(1, math.min((pos.line - 1) * 4 + 1, count))
    vim.api.nvim_win_set_cursor(parent, { line, 0 })
    vim.api.nvim_win_call(parent, function()
      vim.cmd("normal! zz")
    end)
    -- Hand focus back to the editor: like VS Code, the minimap is a scrollbar
    -- to operate, not a pane the cursor stays in.
    vim.api.nvim_set_current_win(parent)
  end

  local function scroll_parent(amount)
    local cursor = vim.api.nvim_win_get_cursor(parent)
    local count = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(parent))
    local line = math.max(1, math.min(cursor[1] + amount, count))
    vim.api.nvim_win_set_cursor(parent, { line, cursor[2] })
    vim.api.nvim_win_call(parent, function()
      vim.cmd("normal! zz")
    end)
  end

  for _, lhs in ipairs({ "<LeftMouse>", "<LeftDrag>" }) do
    vim.keymap.set("n", lhs, jump_to_mouse, { buffer = buf })
  end
  for _, map in ipairs({ { "j", 4 }, { "<Down>", 4 }, { "k", -4 }, { "<Up>", -4 } }) do
    vim.keymap.set("n", map[1], function()
      scroll_parent(map[2])
    end, { buffer = buf })
  end
end

function M.apply()
  vim.schedule(function()
    local minimap = find_minimap()
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
    -- While the minimap itself is focused, judge eligibility by its parent.
    if minimap and win == minimap.win and minimap.parent then
      win = minimap.parent
    end
    local should_open = enabled and eligible(win)
    if should_open and not minimap then
      require("codewindow").open_minimap()
      minimap = find_minimap()
      if minimap then
        attach(minimap.buf, minimap.win, minimap.parent)
      end
    elseif not should_open and minimap then
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
