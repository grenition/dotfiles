local M = {}

local state = {}

local persistent_tool_filetypes = {
  ["neo-tree"] = true,
  netrw = true,
}

local tool_filetypes = {
  ["neo-tree"] = true,
  netrw = true,
  qf = true,
  trouble = true,
}

local function tab_state(tab)
  state[tab] = state[tab] or { tools = {} }
  return state[tab]
end

local function valid_window(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function picker_for_window(win)
  if not valid_window(win) or not Snacks or not Snacks.picker then
    return
  end

  local ok, pickers = pcall(Snacks.picker.get)
  if not ok then
    return
  end

  for _, picker in ipairs(pickers) do
    local windows = {
      picker.input and picker.input.win,
      picker.list and picker.list.win,
      picker.preview and picker.preview.win,
      picker.layout and picker.layout.root,
    }
    if picker.layout then
      vim.list_extend(windows, vim.tbl_values(picker.layout.wins or {}))
      vim.list_extend(windows, picker.layout.box_wins or {})
    end

    for _, candidate in ipairs(windows) do
      if candidate and candidate.win == win then
        return picker
      end
    end
  end
end

function M.is_editor(win)
  if not valid_window(win) or vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local filetype = vim.bo[buf].filetype
  return vim.bo[buf].buftype == "" and not tool_filetypes[filetype] and not filetype:match("^snacks_")
end

local function tool_kind(win)
  if M.is_editor(win) then
    return "editor"
  end

  local picker = picker_for_window(win)
  if picker then
    return picker.opts.source == "explorer" and "persistent" or "transient"
  end

  if not valid_window(win) then
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local filetype = vim.bo[buf].filetype
  if persistent_tool_filetypes[filetype] then
    return "persistent"
  end

  if vim.bo[buf].buftype == "terminal" then
    local terminal = vim.b[buf].snacks_terminal
    return type(terminal) == "table" and terminal.cmd ~= nil and "transient" or "persistent"
  end

  return "transient"
end

local function track(win)
  if not valid_window(win) then
    return
  end

  local current = tab_state(vim.api.nvim_win_get_tabpage(win))
  if M.is_editor(win) then
    current.editor = win
    return
  end

  current.tools = vim.tbl_filter(function(candidate)
    return candidate ~= win and valid_window(candidate)
  end, current.tools)
  table.insert(current.tools, win)
end

local function editor_window(tab)
  local current = tab_state(tab)
  if valid_window(current.editor) and M.is_editor(current.editor) then
    return current.editor
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if M.is_editor(win) then
      current.editor = win
      return win
    end
  end
end

local function last_tool_window(tab)
  local tools = tab_state(tab).tools
  for index = #tools, 1, -1 do
    local win = tools[index]
    if valid_window(win) and not M.is_editor(win) then
      return win
    end
    table.remove(tools, index)
  end
end

local function last_transient_window(tab)
  local tools = tab_state(tab).tools
  for index = #tools, 1, -1 do
    local win = tools[index]
    if valid_window(win) and tool_kind(win) == "transient" then
      return win
    end
    if not valid_window(win) then
      table.remove(tools, index)
    end
  end
end

local function close_window(win)
  local picker = picker_for_window(win)
  if picker then
    picker:close()
    return true
  end

  local buf = valid_window(win) and vim.api.nvim_win_get_buf(win) or nil
  if buf and vim.bo[buf].buftype == "terminal" then
    local terminal = vim.b[buf].snacks_terminal
    if type(terminal) == "table" and terminal.cmd ~= nil and Snacks and Snacks.terminal then
      for _, candidate in ipairs(Snacks.terminal.list()) do
        if candidate.buf == buf then
          candidate:close()
          return true
        end
      end
    end
  end

  return pcall(vim.api.nvim_win_close, win, false)
end

function M.focus_editor()
  local current = vim.api.nvim_get_current_win()
  if M.is_editor(current) then
    return false
  end

  local editor = editor_window(vim.api.nvim_get_current_tabpage())
  if editor then
    vim.api.nvim_set_current_win(editor)
    return true
  end
  return false
end

function M.close_tool_window()
  local tab = vim.api.nvim_get_current_tabpage()
  local current = vim.api.nvim_get_current_win()
  local target = M.is_editor(current) and last_tool_window(tab) or current

  if not target or M.is_editor(target) then
    return false
  end

  pcall(vim.cmd.stopinsert)
  local closed = close_window(target)
  M.focus_editor()
  return closed
end

function M.close_transient_window()
  local tab = vim.api.nvim_get_current_tabpage()
  local current = vim.api.nvim_get_current_win()
  local target = tool_kind(current) == "transient" and current or last_transient_window(tab)

  if not target then
    return false
  end

  pcall(vim.cmd.stopinsert)
  local closed = close_window(target)
  M.focus_editor()
  return closed
end

function M.close_all_tool_windows()
  local tab = vim.api.nvim_get_current_tabpage()
  local editor = editor_window(tab)
  if not editor then
    return false
  end

  pcall(vim.cmd.stopinsert)
  vim.api.nvim_set_current_win(editor)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if valid_window(win) and not M.is_editor(win) then
      pcall(close_window, win)
    end
  end
  return true
end

local function escape()
  vim.schedule(function()
    local current = vim.api.nvim_get_current_win()
    if tool_kind(current) == "persistent" then
      M.focus_editor()
    else
      M.close_transient_window()
    end
    vim.cmd.nohlsearch()
    LazyVim.cmp.actions.snippet_stop()
  end)
  return "<Esc>"
end

local function terminal_escape()
  vim.schedule(function()
    pcall(vim.cmd.stopinsert)
    local current = vim.api.nvim_get_current_win()
    if tool_kind(current) == "persistent" then
      M.focus_editor()
    else
      M.close_transient_window()
    end
  end)
end

local function close_tool_window()
  vim.schedule(M.close_tool_window)
end

local function close_all_tool_windows()
  vim.schedule(M.close_all_tool_windows)
end

local function set_keymaps(buffer)
  local opts = { silent = true }
  if buffer then
    opts.buffer = buffer
  end

  vim.keymap.set(
    { "i", "n", "s", "x" },
    "<Esc>",
    escape,
    vim.tbl_extend("force", opts, {
      expr = true,
      desc = "Close Transient Tool / Focus Editor",
    })
  )
  vim.keymap.set(
    "t",
    "<Esc>",
    terminal_escape,
    vim.tbl_extend("force", opts, { desc = "Close Transient Tool / Focus Editor" })
  )
  vim.keymap.set(
    { "i", "n", "s", "t", "x" },
    "<C-Esc>",
    close_tool_window,
    vim.tbl_extend("force", opts, {
      desc = "Close Active Tool Window",
    })
  )
  vim.keymap.set(
    { "i", "n", "s", "t", "x" },
    "<C-S-Esc>",
    close_all_tool_windows,
    vim.tbl_extend("force", opts, { desc = "Close All Tool Windows" })
  )
end

function M.setup()
  set_keymaps()
  track(vim.api.nvim_get_current_win())

  local group = vim.api.nvim_create_augroup("rider_tool_windows", { clear = true })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "TermOpen", "WinEnter" }, {
    group = group,
    callback = function(event)
      local win = vim.api.nvim_get_current_win()
      track(win)
      vim.schedule(function()
        if valid_window(win) and not M.is_editor(win) and vim.api.nvim_win_get_buf(win) == event.buf then
          set_keymaps(event.buf)
        end
      end)
    end,
  })
end

return M
