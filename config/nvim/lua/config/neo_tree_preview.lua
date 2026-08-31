local M = {}

M.options = {
  use_float = false,
  use_snacks_image = false,
  use_image_nvim = false,
}

local preview_buffer

local function preview_api()
  -- Neo-tree does not expose automatic preview through its public API. Keep
  -- this locked-revision integration contained here so upgrades have one
  -- compatibility boundary to verify.
  return require("neo-tree.sources.common.preview")
end

local function discard_previous_preview(next_buffer)
  local buffer = preview_buffer
  if not buffer or buffer == next_buffer then
    return
  end

  preview_buffer = nil
  if not vim.api.nvim_buf_is_valid(buffer) then
    return
  end
  if vim.bo[buffer].modified or vim.fn.bufwinid(buffer) ~= -1 then
    vim.b[buffer].jetbrains_preview = nil
    return
  end

  vim.b[buffer].jetbrains_preview = nil
  pcall(vim.api.nvim_buf_delete, buffer, {})
end

function M.pin(path)
  local buffer = preview_buffer
  if not buffer or not vim.api.nvim_buf_is_valid(buffer) then
    preview_buffer = nil
    return
  end

  if vim.fs.normalize(vim.api.nvim_buf_get_name(buffer)) == vim.fs.normalize(path) then
    vim.b[buffer].jetbrains_preview = nil
    preview_buffer = nil
  end
end

function M.show_selected()
  if vim.bo.filetype ~= "neo-tree" then
    return
  end

  local state = require("neo-tree.sources.manager").get_state_for_window()
  if not state or not state.tree then
    return
  end

  local preview = preview_api()
  local node = state.tree:get_node()
  if not node or node.type ~= "file" then
    preview.hide()
    return
  end

  local existing_buffer = vim.fn.bufnr(node.path)
  local owns_buffer = existing_buffer < 0
    or vim.fn.buflisted(existing_buffer) == 0
    or vim.b[existing_buffer].jetbrains_preview == true

  state.config = M.options
  preview.show(state)

  local buffer = vim.fn.bufnr(node.path)
  if buffer < 0 then
    return
  end

  discard_previous_preview(buffer)
  vim.bo[buffer].buflisted = true
  vim.b[buffer].jetbrains_preview = owns_buffer or nil
  preview_buffer = owns_buffer and buffer or nil
end

function M.hide()
  preview_api().hide()
end

return M
