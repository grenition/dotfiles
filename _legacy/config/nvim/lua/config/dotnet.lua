local M = {}

function M.env()
  local dotnet = vim.fn.resolve(vim.fn.exepath("dotnet"))
  local cellar = vim.fs.dirname(vim.fs.dirname(dotnet))
  local root = cellar .. "/libexec"

  if vim.fn.executable(root .. "/dotnet") == 1 then
    return { DOTNET_ROOT = root }
  end

  return nil
end

return M
