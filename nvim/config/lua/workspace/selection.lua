local M = {}
local fn = vim.fn

local function normal(keys) vim.cmd.normal { args = { vim.keycode(keys) }, bang = true } end

local function before(a, b) return a[2] < b[2] or (a[2] == b[2] and a[3] < b[3]) end

local function select_range(anchor, cursor)
  fn.setpos(".", anchor)
  normal "o"
  fn.setpos(".", cursor)
end

local function bounds()
  local first, last = fn.getpos "v", fn.getpos "."
  if before(last, first) then
    first, last = last, first
  end
  return first, last
end

local function line_end(row)
  local line = fn.getline(row)
  local col = fn.byteidx(line, math.max(0, fn.strchars(line, true) - 1)) + 1
  return { 0, row, math.max(1, col), 0 }
end

local function expand_text(first, last)
  if first[2] == last[2] then
    local quotes = [[\v"([^"\\]|\\.)*"|'([^'\\]|\\.)*'|`([^`\\]|\\.)*`]]
    local line, offset = fn.getline(first[2]), 0
    while offset < #line do
      local match = fn.matchstrpos(line, quotes, offset)
      local start, finish = match[2] + 1, match[3]
      if finish < 0 or start > first[3] then break end
      if finish >= last[3] and (start < first[3] or finish > last[3]) then
        select_range({ 0, first[2], start, 0 }, { 0, last[2], finish, 0 })
        return
      end
      offset = finish
    end
  end
  select_range({ 0, first[2], 1, 0 }, line_end(last[2]))
end

function M.expand()
  if fn.mode() ~= "v" then return normal "v" end
  local first, last = bounds()
  local origin = vim.w.selection_origin or fn.getpos "v"
  if not vim.w.selection_origin and vim.deep_equal(first, last) then
    normal "iw"
  else
    local finish = line_end(fn.line "$")
    if first[2] == 1 and first[3] == 1 and not before(last, finish) then
      select_range(origin, origin)
      vim.w.selection_origin = nil
      return
    end
    if vim.treesitter.get_parser(0, nil, { error = false }) then
      vim.treesitter.select "parent"
    else
      expand_text(first, last)
    end
    local left, right = bounds()
    if not before(left, first) and not before(last, right) then select_range({ 0, 1, 1, 0 }, finish) end
  end
  vim.w.selection_origin = origin
end

local function word_at(pos)
  normal "<Esc>"
  fn.setpos(".", pos)
  normal "viw"
  return bounds()
end

function M.motion(key, word_motion)
  return function()
    local count = vim.v.count1
    local origin = vim.w.selection_origin
    if not origin then return normal(count .. key) end

    local anchor, cursor = fn.getpos "v", fn.getpos "."
    local start = word_at(cursor)
    normal "<Esc>"
    fn.setpos(".", start)
    normal(count .. word_motion)
    normal "viw"
    local first, last = bounds()
    local backwards = before(first, anchor)
    if backwards ~= before(cursor, anchor) then
      local left, right = word_at(anchor)
      anchor = backwards and right or left
    end
    select_range(anchor, backwards and first or last)
    vim.w.selection_origin = origin
  end
end

return M
