local M = {}

local function command_action(state, name)
  return function()
    local command = state.commands and state.commands[name]
    if not command then
      vim.notify("neo-tree command not available: " .. name, vim.log.levels.WARN)
      return
    end
    command(state)
  end
end

local function copy_action(value)
  return function()
    vim.fn.setreg("+", value)
    vim.notify("Copied: " .. value)
  end
end

local function reveal_action(path)
  return function()
    if vim.fn.has("mac") == 1 and vim.fn.executable("open") == 1 then
      vim.fn.system({ "open", "-R", path })
      return
    end
    if vim.fn.executable("xdg-open") == 1 then
      vim.fn.system({ "xdg-open", vim.fn.fnamemodify(path, ":h") })
      return
    end
    vim.notify("No file manager available to reveal path", vim.log.levels.WARN)
  end
end

local function code_action_action(win)
  return function()
    local buf = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) or nil
    if not buf or win == vim.api.nvim_get_current_win() or vim.bo[buf].filetype == "neo-tree" then
      vim.notify("No previous window for code actions", vim.log.levels.WARN)
      return
    end
    vim.api.nvim_set_current_win(win)
    require("fzf-lua").lsp_code_actions()
  end
end

-- Rendered through vim.ui.select, which plugins/picker.lua routes to the
-- fzf-lua UI selector. Keep the entry order of the former nui.menu layout.
function M.open(state)
  local tree = state.tree
  if not tree then
    return
  end
  local node = tree:get_node()
  if not node then
    return
  end

  local path = node:get_id()
  local previous_win = vim.fn.win_getid(vim.fn.winnr("#"))
  local reveal_label = vim.fn.has("mac") == 1 and "Reveal in Finder" or "Reveal in File Manager"

  local entries = {
    { label = "New File", run = command_action(state, "add") },
    { label = "New Directory", run = command_action(state, "add_directory") },
    { label = "Rename", run = command_action(state, "rename") },
    { label = "Move", run = command_action(state, "move") },
    { label = "Delete", run = command_action(state, "delete") },
    { label = "Copy (neo-tree)", run = command_action(state, "copy") },
    { label = "Cut", run = command_action(state, "cut_to_clipboard") },
    { label = "Paste", run = command_action(state, "paste_from_clipboard") },
    { label = "Copy Absolute Path", run = copy_action(path) },
    { label = "Copy Relative Path", run = copy_action(vim.fn.fnamemodify(path, ":.")) },
    { label = "Copy Filename", run = copy_action(vim.fn.fnamemodify(path, ":t")) },
    { label = "Copy Directory", run = copy_action(vim.fn.fnamemodify(path, ":h")) },
  }

  if node.type == "file" then
    entries[#entries + 1] = { label = "Open in Split", run = command_action(state, "open_split") }
    entries[#entries + 1] = { label = "Open in Vertical Split", run = command_action(state, "open_vsplit") }
    entries[#entries + 1] = { label = "Open in Tab", run = command_action(state, "open_tabnew") }
  end

  entries[#entries + 1] = { label = reveal_label, run = reveal_action(path) }
  entries[#entries + 1] = { label = "Code Actions (LSP)", run = code_action_action(previous_win) }

  vim.ui.select(entries, {
    prompt = vim.fn.fnamemodify(path, ":t") .. " ",
    format_item = function(entry)
      return entry.label
    end,
  }, function(choice)
    if choice and choice.run then
      choice.run()
    end
  end)
end

return M
