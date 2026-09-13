local M = {}

local WIDTH = 40

local function menu_api()
  return require("nui.menu")
end

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
    require("config.code_actions_menu").open()
  end
end

function M.open(state)
  local Menu = menu_api()

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

  local lines = {
    Menu.item("New File", { run = command_action(state, "add") }),
    Menu.item("New Directory", { run = command_action(state, "add_directory") }),
    Menu.item("Rename", { run = command_action(state, "rename") }),
    Menu.item("Move", { run = command_action(state, "move") }),
    Menu.item("Delete", { run = command_action(state, "delete") }),
    Menu.separator(),
    Menu.item("Copy (neo-tree)", { run = command_action(state, "copy") }),
    Menu.item("Cut", { run = command_action(state, "cut_to_clipboard") }),
    Menu.item("Paste", { run = command_action(state, "paste_from_clipboard") }),
    Menu.separator(),
    Menu.item("Copy Absolute Path", { run = copy_action(path) }),
    Menu.item("Copy Relative Path", { run = copy_action(vim.fn.fnamemodify(path, ":.")) }),
    Menu.item("Copy Filename", { run = copy_action(vim.fn.fnamemodify(path, ":t")) }),
    Menu.item("Copy Directory", { run = copy_action(vim.fn.fnamemodify(path, ":h")) }),
    Menu.separator(),
  }

  if node.type == "file" then
    lines[#lines + 1] = Menu.item("Open in Split", { run = command_action(state, "open_split") })
    lines[#lines + 1] = Menu.item("Open in Vertical Split", { run = command_action(state, "open_vsplit") })
    lines[#lines + 1] = Menu.item("Open in Tab", { run = command_action(state, "open_tabnew") })
  end

  lines[#lines + 1] = Menu.item(reveal_label, { run = reveal_action(path) })
  lines[#lines + 1] = Menu.separator()
  lines[#lines + 1] = Menu.item("Code Actions (LSP)", { run = code_action_action(previous_win) })

  local menu = Menu({
    position = { row = 1, col = 0 },
    relative = "cursor",
    border = {
      style = "rounded",
      text = {
        top = " " .. vim.fn.fnamemodify(path, ":t") .. " ",
        top_align = "center",
      },
    },
    win_options = {
      cursorline = true,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual",
    },
  }, {
    lines = lines,
    min_width = WIDTH,
    max_width = WIDTH,
    keymap = {
      close = { "<Esc>", "q" },
      focus_next = { "j", "<Down>" },
      focus_prev = { "k", "<Up>" },
      submit = { "<CR>" },
    },
    on_submit = function(item)
      if item and item.run then
        item.run()
      end
    end,
  })

  menu:mount()
end

return M
