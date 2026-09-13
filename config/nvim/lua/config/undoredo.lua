-- Cross-buffer undo/redo for LSP workspace edits.
--
-- Rename (<leader>rr) and code actions funnel every client-side workspace
-- edit through vim.lsp.util.apply_workspace_edit, so wrapping that one
-- public function records each edit's touched buffers. u/U then step
-- undo/redo through all of them at once, matching repeated single-buffer
-- presses. Only text edits are covered: file create/rename/delete
-- operations are not undoable.

local M = {}

local apply = vim.lsp.util.apply_workspace_edit

-- Buffers touched by the most recent workspace edit: { [bufnr] = true }.
local session = nil

local function collect_uris(edit)
  local uris = {}
  for uri in pairs(edit.changes or {}) do
    uris[uri] = true
  end
  for _, change in ipairs(edit.documentChanges or {}) do
    if change.textDocument and change.textDocument.uri then
      uris[change.textDocument.uri] = true
    end
  end
  return uris
end

vim.lsp.util.apply_workspace_edit = function(edit, offset_encoding)
  local result = apply(edit, offset_encoding)
  local buffers = {}
  for uri in pairs(collect_uris(edit or {})) do
    local bufnr = vim.uri_to_bufnr(uri)
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
      buffers[bufnr] = true
    end
  end
  session = { buffers = buffers }
  return result
end

local function propagates_to(bufnr, current)
  if bufnr == current then
    return false
  end
  return vim.api.nvim_buf_is_valid(bufnr)
    and vim.api.nvim_buf_is_loaded(bufnr)
    and vim.bo[bufnr].buflisted
    and vim.bo[bufnr].modifiable
end

local function step(command)
  -- The file tree is not an undo target: file operations there are not
  -- undoable and neo-tree's trash is the recovery path.
  if vim.bo.filetype == "neo-tree" or not vim.bo.modifiable then
    return
  end
  local current = vim.api.nvim_get_current_buf()
  local in_session = session ~= nil and session.buffers[current] ~= nil
  pcall(vim.cmd, command)
  if not in_session then
    return
  end
  for bufnr in pairs(session.buffers) do
    if propagates_to(bufnr, current) then
      vim.api.nvim_buf_call(bufnr, function()
        pcall(vim.cmd, command)
      end)
    end
  end
end

function M.undo()
  step("undo")
end

function M.redo()
  step("redo")
end

return M
