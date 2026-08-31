local M = {}

local namespace = vim.api.nvim_create_namespace("navigable_target")

local function url_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local column = vim.api.nvim_win_get_cursor(0)[2] + 1
  local offset = 1

  while true do
    local first, last = line:find("https?://[^%s%\"'<>]+", offset)
    if not first then
      return nil
    end

    while last >= first and line:sub(last, last):match("[%),%.%;%]%}]") do
      last = last - 1
    end
    if column >= first and column <= last then
      return {
        kind = "url",
        value = line:sub(first, last),
        first = first,
        last = last,
      }
    end
    offset = last + 1
  end
end

local function token_range(token)
  local line = vim.api.nvim_get_current_line()
  local column = vim.api.nvim_win_get_cursor(0)[2] + 1
  local offset = 1

  while true do
    local first, last = line:find(token, offset, true)
    if not first then
      return nil, nil
    end
    if column >= first and column <= last then
      return first, last
    end
    offset = last + 1
  end
end

local function project_root(path)
  return vim.fs.root(path, { ".git", ".gitlab-ci-ls.yml", "Makefile", "package.json" })
end

local function local_file_under_cursor()
  local ok, displayed_token = pcall(vim.fn.expand, "<cfile>")
  if not ok then
    return nil
  end
  if displayed_token == "" or displayed_token:match("^https?://") then
    return nil
  end

  local first, last = token_range(displayed_token)
  if not first then
    return nil
  end

  local token = displayed_token
  if token:match("^file://") then
    token = vim.uri_to_fname(token)
  end
  token = vim.fs.normalize(token)

  local current_file = vim.api.nvim_buf_get_name(0)
  local buffer_dir = current_file ~= "" and vim.fs.dirname(current_file) or vim.uv.cwd()
  local root = project_root(current_file ~= "" and current_file or buffer_dir)
  local candidates = {}

  if vim.fs.abspath(token) == token then
    table.insert(candidates, token)
    if root then
      local project_relative = token:gsub("^/+", "")
      table.insert(candidates, vim.fs.joinpath(root, project_relative))
    end
  else
    table.insert(candidates, vim.fs.joinpath(buffer_dir, token))
    if root and root ~= buffer_dir then
      table.insert(candidates, vim.fs.joinpath(root, token))
    end
  end

  for _, candidate in ipairs(candidates) do
    local stat = vim.uv.fs_stat(candidate)
    if stat and stat.type == "file" then
      return {
        kind = "file",
        value = candidate,
        first = first,
        last = last,
      }
    end
  end
end

function M.target_under_cursor()
  return url_under_cursor() or local_file_under_cursor()
end

function M.open_under_cursor()
  local target = M.target_under_cursor()
  if not target then
    return false
  end

  if target.kind == "url" then
    vim.ui.open(target.value)
    return true
  end

  if target.kind == "file" then
    vim.cmd.edit(vim.fn.fnameescape(target.value))
    return true
  end

  return false
end

function M.update_highlight(event)
  local bufnr = event and event.buf or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

  if bufnr ~= vim.api.nvim_get_current_buf() or vim.bo[bufnr].buftype ~= "" then
    return
  end

  local target = M.target_under_cursor()
  if not target then
    return
  end

  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  vim.api.nvim_buf_set_extmark(bufnr, namespace, row, target.first - 1, {
    end_col = target.last,
    hl_group = "NavigableTarget",
    hl_mode = "combine",
    priority = 200,
  })
end

function M.setup_highlight(group)
  vim.api.nvim_set_hl(0, "NavigableTarget", { underline = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI" }, {
    group = group,
    callback = M.update_highlight,
  })
end

function M.goto_definition()
  if M.open_under_cursor() then
    return
  end

  if vim.lsp.get_clients({ bufnr = 0, name = "roslyn_ls" })[1] then
    vim.lsp.buf.definition()
  else
    require("fzf-lua").lsp_definitions()
  end
end

return M
