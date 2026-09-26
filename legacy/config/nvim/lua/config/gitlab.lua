local M = {}

local marker = ".gitlab-ci-ls.yml"

function M.template_root(path)
  if not path or path == "" then
    return nil
  end
  return vim.fs.root(path, { marker })
end

function M.is_ci_file(path)
  if not path or path == "" then
    return false
  end

  local name = vim.fs.basename(path)
  if name == ".gitlab-ci.yml" or name == ".gitlab-ci.yaml" then
    return true
  end

  local extension = name:match("%.([^.]+)$")
  return (extension == "yml" or extension == "yaml") and M.template_root(path) ~= nil
end

return M
