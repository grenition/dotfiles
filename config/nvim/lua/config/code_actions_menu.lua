local M = {}

local WIDTH = 50

local function menu_api()
  return require("nui.menu")
end

local function apply_action(action, client)
  local bufnr = vim.api.nvim_get_current_buf()
  if not action.edit and not action.command and action.data then
    client:request("codeAction/resolve", action, function(err, resolved)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR)
        return
      end
      apply_action(resolved, client)
    end, bufnr)
    return
  end
  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
  end
  if action.command then
    local command = type(action.command) == "table" and action.command or action
    local fn = client.commands[command.command] or vim.lsp.commands[command.command]
    if fn then
      local pos = vim.api.nvim_win_get_cursor(0)
      fn(command, { bufnr = bufnr, client_id = client.id })
      if vim.api.nvim_win_get_cursor(0)[1] ~= pos[1] then
        vim.cmd("normal! zv")
      end
    else
      client:request("workspace/executeCommand", command, function(err)
        if err then
          vim.notify(err.message, vim.log.levels.ERROR)
        end
      end, bufnr)
    end
  end
end

local function show_menu(items)
  local Menu = menu_api()
  local lines = {}
  for _, entry in ipairs(items) do
    lines[#lines + 1] = Menu.item(entry.action.title, entry)
  end

  local menu = Menu({
    position = { row = 1, col = 0 },
    relative = "cursor",
    border = {
      style = "rounded",
      text = {
        top = " Code Actions ",
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
      local client = vim.lsp.get_client_by_id(item.client_id)
      if client and item.action then
        apply_action(item.action, client)
      end
    end,
  })

  menu:mount()
end

function M.open()
  local mode = vim.api.nvim_get_mode().mode
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local lnum = vim.api.nvim_win_get_cursor(win)[1] - 1
  local visual = mode == "v" or mode == "V" or mode == "\22"
  local start, end_
  if visual then
    start = vim.api.nvim_buf_get_mark(bufnr, "<")
    end_ = vim.api.nvim_buf_get_mark(bufnr, ">")
  end

  local ok, err = pcall(vim.lsp.buf_request_all, bufnr, "textDocument/codeAction", function(client)
    local params
    if visual then
      params = vim.lsp.util.make_given_range_params(start, end_, bufnr, client.offset_encoding)
    else
      params = vim.lsp.util.make_range_params(win, client.offset_encoding)
    end
    local diagnostics = {}
    for _, diagnostic in ipairs(vim.diagnostic.get(bufnr, { lnum = lnum })) do
      local lsp_diagnostic = diagnostic.user_data and diagnostic.user_data.lsp
      if lsp_diagnostic then
        diagnostics[#diagnostics + 1] = lsp_diagnostic
      end
    end
    params.context = { diagnostics = diagnostics }
    return params
  end, function(result)
    local items = {}
    for client_id, response in pairs(result) do
      local actions = response and response.result
      if type(actions) == "table" then
        for _, action in ipairs(actions) do
          items[#items + 1] = { action = action, client_id = client_id }
        end
      end
    end
    if #items == 0 then
      vim.notify("No code actions available", vim.log.levels.INFO)
      return
    end
    show_menu(items)
  end)
  if not ok then
    vim.notify(err, vim.log.levels.ERROR)
  end
end

return M
