local M = {}

function M.close(buffer)
  buffer = buffer or vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(buffer) then
    return
  end

  if vim.bo[buffer].modified then
    vim.notify("Save or discard changes before closing this buffer", vim.log.levels.WARN, {
      title = "Unsaved changes",
    })
    return
  end

  local ok, err = pcall(vim.api.nvim_buf_delete, buffer, {})
  if ok then
    return
  end

  local message = tostring(err):gsub("^Vim:E%d+: ", "")
  vim.notify(message, vim.log.levels.WARN, { title = "Buffer not closed" })
end

return M
