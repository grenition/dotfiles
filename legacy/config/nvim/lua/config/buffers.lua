local M = {}

function M.show_in_bufferline(buffer)
  return vim.api.nvim_buf_get_name(buffer) ~= ""
end

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

  local replacement
  for _, listed in ipairs(vim.api.nvim_list_bufs()) do
    if listed ~= buffer and vim.bo[listed].buflisted then
      replacement = listed
      break
    end
  end
  if not replacement then
    replacement = vim.api.nvim_create_buf(true, false)
  end

  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    for _, window in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
      if vim.api.nvim_win_get_buf(window) == buffer then
        vim.api.nvim_win_set_buf(window, replacement)
      end
    end
  end

  local ok, err = pcall(vim.api.nvim_buf_delete, buffer, {})
  if ok then
    return
  end

  local message = tostring(err):gsub("^Vim:E%d+: ", "")
  vim.notify(message, vim.log.levels.WARN, { title = "Buffer not closed" })
end

return M
