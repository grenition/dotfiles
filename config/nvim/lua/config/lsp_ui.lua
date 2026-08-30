local M = {}

local selection_file = vim.fs.joinpath(vim.fn.stdpath("config"), "lua/config/lsp_ui_selection.lua")
local selection = { inlay_hints = true, code_lens = true }
local selection_stamp

local labels = {
  inlay_hints = "Inlay hints",
  code_lens = "CodeLens references",
}

local function selection_file_stamp()
  local stat = vim.uv.fs_stat(selection_file)
  if not stat then
    return nil
  end

  return table.concat({ stat.mtime.sec, stat.mtime.nsec, stat.size }, ":")
end

local function load_selection()
  local ok, saved = pcall(dofile, selection_file)
  if not ok or type(saved) ~= "table" then
    return nil
  end

  local before = vim.deepcopy(selection)
  for name, default in pairs(selection) do
    selection[name] = type(saved[name]) == "boolean" and saved[name] or default
  end

  return before.inlay_hints ~= selection.inlay_hints or before.code_lens ~= selection.code_lens
end

local function persist_selection()
  vim.fn.writefile({
    "-- Updated by <Space>uh and <Space>ul. Keep this file in the dotfiles repository.",
    "return {",
    string.format("  inlay_hints = %s,", tostring(selection.inlay_hints)),
    string.format("  code_lens = %s,", tostring(selection.code_lens)),
    "}",
  }, selection_file)
  package.loaded["config.lsp_ui_selection"] = vim.deepcopy(selection)
  selection_stamp = selection_file_stamp()
end

function M.apply_inlay_hints(bufnr)
  vim.lsp.inlay_hint.enable(selection.inlay_hints, { bufnr = bufnr })
end

function M.apply_code_lenses(bufnr)
  vim.lsp.codelens.enable(selection.code_lens, { bufnr = bufnr })
end

function M.apply()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      M.apply_inlay_hints(bufnr)
      M.apply_code_lenses(bufnr)
    end
  end
end

function M.set(name, enabled)
  if selection[name] == nil then
    error("Unknown LSP UI setting: " .. name)
  end

  selection[name] = enabled
  persist_selection()
  M.apply()
  vim.notify(string.format("Saved %s: %s", labels[name], enabled and "shown" or "hidden"), vim.log.levels.INFO)
end

function M.pick(name)
  if selection[name] == nil then
    error("Unknown LSP UI setting: " .. name)
  end

  vim.ui.select({ true, false }, {
    prompt = labels[name],
    format_item = function(enabled)
      local current = enabled == selection[name] and " (current)" or ""
      return (enabled and "Show" or "Hide") .. current
    end,
  }, function(enabled)
    if enabled ~= nil then
      M.set(name, enabled)
    end
  end)
end

local function reload_selection_if_changed()
  local stamp = selection_file_stamp()
  if stamp == selection_stamp then
    return
  end

  local changed = load_selection()
  if changed == nil then
    return
  end

  selection_stamp = stamp
  if changed then
    M.apply()
  end
end

local group = vim.api.nvim_create_augroup("lsp_ui_selection", { clear = true })
vim.api.nvim_create_autocmd("FocusGained", {
  group = group,
  callback = reload_selection_if_changed,
})

load_selection()
selection_stamp = selection_file_stamp()
M.apply()

return M
