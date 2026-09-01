local M = {}

local pending_requests = {}
local request_generation = 0
local active_match

local function cancel_pending_requests()
  request_generation = request_generation + 1
  for _, request in ipairs(pending_requests) do
    local client = vim.lsp.get_client_by_id(request.client_id)
    if client then
      client:cancel_request(request.request_id)
    end
  end
  pending_requests = {}
end

local function forget_request(client_id, request_id)
  for index = #pending_requests, 1, -1 do
    local request = pending_requests[index]
    if request.client_id == client_id and request.request_id == request_id then
      table.remove(pending_requests, index)
    end
  end
end

local function clear_active_match()
  if active_match then
    pcall(vim.fn.matchdelete, active_match.id, active_match.winid)
    active_match = nil
  end
end

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

local function markdown_link_range()
  if vim.bo.filetype ~= "markdown" and vim.bo.filetype ~= "markdown.mdx" then
    return nil, nil
  end

  local line = vim.api.nvim_get_current_line()
  local column = vim.api.nvim_win_get_cursor(0)[2] + 1
  local patterns = {
    "%[%[([^%]]+)%]%]", -- [[wiki link]]
    "%[([^%]]+)%]%([^%)]+%)", -- [label](target)
    "%[([^%]]+)%]%[[^%]]*%]", -- [label][reference]
    "%[([^%]]+)%]", -- [reference]
  }

  for pattern_index, pattern in ipairs(patterns) do
    local offset = 1
    while true do
      local first, last, label = line:find(pattern, offset)
      if not first then
        break
      end
      if column >= first and column <= last then
        local prefix_length = pattern_index == 1 and 2 or 1
        local label_first = first + prefix_length
        return label_first, label_first + #label - 1
      end
      offset = last + 1
    end
  end
end

local function definition_source_range()
  local first, last = markdown_link_range()
  if first then
    return first, last
  end

  local word_ok, word = pcall(vim.fn.expand, "<cword>")
  if word_ok and word ~= "" then
    return token_range(word)
  end
end

local function project_root(path)
  return vim.fs.root(path, { ".git", ".gitlab-ci-ls.yml", "Makefile", "package.json" })
end

local function local_file_from_url(target)
  local current_file = vim.api.nvim_buf_get_name(0)
  local root = project_root(current_file ~= "" and current_file or vim.uv.cwd())
  if not root then
    return nil
  end

  local url_path = target.value:match("^https?://[^/]+(/.*)$")
  if not url_path then
    return nil
  end

  local decoded_ok, decoded = pcall(vim.uri_decode, url_path)
  if not decoded_ok then
    return nil
  end
  local segments = vim.split(decoded, "/", { plain = true, trimempty = true })
  local repository = vim.fs.basename(root)
  local repository_index
  for index, segment in ipairs(segments) do
    if segment == repository then
      repository_index = index
      break
    end
  end
  if not repository_index then
    return nil
  end

  -- A Git ref may itself contain slashes (for example release/5), so test
  -- every suffix after the repository name instead of guessing its length.
  for index = repository_index + 1, #segments do
    local candidate = vim.fs.joinpath(root, unpack(segments, index))
    local stat = vim.uv.fs_stat(candidate)
    if stat and stat.type == "file" then
      return vim.tbl_extend("force", target, { kind = "file", value = candidate })
    end
  end
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
  local url = url_under_cursor()
  if url then
    return local_file_from_url(url) or url
  end
  return local_file_under_cursor()
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

local function set_highlight(target, group)
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local winid = vim.api.nvim_get_current_win()
  clear_active_match()
  local match_id = vim.fn.matchaddpos(group, { { row + 1, target.first, target.last - target.first + 1 } }, 200, -1, {
    window = winid,
  })
  if match_id ~= -1 then
    active_match = { id = match_id, winid = winid }
  end
end

function M.update_highlight(event)
  cancel_pending_requests()
  local bufnr = event and event.buf or vim.api.nvim_get_current_buf()
  clear_active_match()

  if bufnr ~= vim.api.nvim_get_current_buf() or vim.bo[bufnr].buftype ~= "" then
    return
  end

  local target = M.target_under_cursor()
  if not target then
    return
  end

  set_highlight(target, "NavigableLink")
end

function M.update_lsp_highlight(event)
  local bufnr = event and event.buf or vim.api.nvim_get_current_buf()
  if bufnr ~= vim.api.nvim_get_current_buf() or vim.bo[bufnr].buftype ~= "" or M.target_under_cursor() then
    return
  end

  cancel_pending_requests()
  local generation = request_generation
  local cursor = vim.api.nvim_win_get_cursor(0)
  local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
  local resolved = false

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client:supports_method("textDocument/definition", bufnr) then
      local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
      local completed = false
      local ok, request_id = client:request("textDocument/definition", params, function(err, result, context)
        completed = true
        if context then
          forget_request(context.client_id, context.request_id)
        end
        if err or not result or next(result) == nil or resolved or generation ~= request_generation then
          return
        end
        if bufnr ~= vim.api.nvim_get_current_buf() or changedtick ~= vim.api.nvim_buf_get_changedtick(bufnr) then
          return
        end
        if not vim.deep_equal(cursor, vim.api.nvim_win_get_cursor(0)) then
          return
        end

        local first, last = definition_source_range()
        if not first or not last then
          return
        end

        resolved = true
        set_highlight({ first = first, last = last }, "NavigableDefinition")
      end, bufnr)
      if ok and request_id and not completed then
        table.insert(pending_requests, { client_id = client.id, request_id = request_id })
      end
    end
  end
end

function M.setup_highlight(group)
  vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI" }, {
    group = group,
    callback = M.update_highlight,
  })
  vim.api.nvim_create_autocmd("CursorHold", {
    group = group,
    callback = M.update_lsp_highlight,
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
