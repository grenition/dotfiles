local M = {}

local escape_desc = "Close transient tool or focus editor"

local persistent_filetypes = {
  ["neo-tree"] = true,
}

local function valid_window(window)
  return window and vim.api.nvim_win_is_valid(window)
end

function M.is_editor(window)
  if not valid_window(window) or vim.api.nvim_win_get_config(window).relative ~= "" then
    return false
  end

  local buffer = vim.api.nvim_win_get_buf(window)
  return vim.bo[buffer].buftype == "" and not persistent_filetypes[vim.bo[buffer].filetype]
end

function M.focus_editor()
  local tab = vim.api.nvim_get_current_tabpage()
  for _, window in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if M.is_editor(window) then
      vim.api.nvim_set_current_win(window)
      return true
    end
  end
  return false
end

function M.focus_or_open_explorer()
  local tab = vim.api.nvim_get_current_tabpage()
  for _, window in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    local buffer = vim.api.nvim_win_get_buf(window)
    if vim.bo[buffer].filetype == "neo-tree" then
      vim.api.nvim_set_current_win(window)
      return
    end
  end
  vim.cmd("Neotree show")
end

local function close_current_tool()
  local window = vim.api.nvim_get_current_win()
  if M.is_editor(window) then
    return false
  end
  pcall(vim.cmd.stopinsert)
  local closed = pcall(vim.api.nvim_win_close, window, false)
  M.focus_editor()
  return closed
end

local function close_all_tools()
  local tab = vim.api.nvim_get_current_tabpage()
  for _, window in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if not M.is_editor(window) then
      pcall(vim.api.nvim_win_close, window, false)
    end
  end
  M.focus_editor()
end

local function escape()
  vim.schedule(function()
    local window = vim.api.nvim_get_current_win()
    if M.is_editor(window) then
      vim.cmd.nohlsearch()
      return
    end

    local buffer = vim.api.nvim_win_get_buf(window)
    if persistent_filetypes[vim.bo[buffer].filetype] or vim.bo[buffer].buftype == "terminal" then
      M.focus_editor()
    else
      close_current_tool()
    end
  end)
  return "<Esc>"
end

local function terminal_escape()
  pcall(vim.cmd.stopinsert)
  vim.schedule(M.focus_editor)
end

local function install_escape(buffer)
  vim.keymap.set({ "n", "s", "x" }, "<Esc>", escape, {
    buffer = buffer,
    desc = escape_desc,
    expr = true,
    silent = true,
  })
end

-- A terminal window drives Escape through the process it hosts: fzf-lua
-- forwards it to fzf so the picker actually closes.  Overwriting that mapping
-- leaves the window open with the focus somewhere else, so keep out of the way.
local function owns_escape(buffer)
  if vim.bo[buffer].buftype ~= "terminal" then
    return false
  end
  for _, keymap in ipairs(vim.api.nvim_buf_get_keymap(buffer, "n")) do
    local lhs = keymap.lhsraw or keymap.lhs or ""
    if (lhs == "\27" or lhs:lower() == "<esc>") and keymap.desc ~= escape_desc then
      return true
    end
  end
  return false
end

function M.setup()
  -- Do not intercept Insert-mode Escape.  In a terminal Option+Backspace is
  -- commonly encoded as Escape followed by Backspace, so an Insert mapping
  -- here turns deletion into a mode/window action.
  vim.keymap.set({ "n", "s", "x" }, "<Esc>", escape, {
    desc = escape_desc,
    expr = true,
    silent = true,
  })
  vim.keymap.set("t", "<Esc>", terminal_escape, { desc = "Focus editor", silent = true })
  vim.keymap.set({ "i", "n", "s", "t", "x" }, "<C-Esc>", close_current_tool, {
    desc = "Close active tool window",
    silent = true,
  })
  vim.keymap.set({ "i", "n", "s", "t", "x" }, "<C-S-Esc>", close_all_tools, {
    desc = "Close all tool windows",
    silent = true,
  })

  local group = vim.api.nvim_create_augroup("tool_window_keymaps", { clear = true })

  -- Buffer-local mappings live on the buffer, so these three events are enough
  -- to cover every buffer once; WinEnter would only repeat the same work.
  vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "TermOpen" }, {
    group = group,
    callback = function(event)
      local buffer = event.buf
      if vim.api.nvim_buf_is_valid(buffer) and not owns_escape(buffer) then
        install_escape(buffer)
      end
    end,
  })

  -- Neo-tree maps <Esc> itself and re-applies its mappings when it re-renders.
  -- The window stays open either way, so keep Escape meaning "focus the editor"
  -- there.  Cheap enough to redo on entry: one table lookup for every other
  -- buffer.
  vim.api.nvim_create_autocmd("WinEnter", {
    group = group,
    callback = function(event)
      local buffer = event.buf
      if vim.api.nvim_buf_is_valid(buffer) and persistent_filetypes[vim.bo[buffer].filetype] then
        install_escape(buffer)
      end
    end,
  })
end

return M
