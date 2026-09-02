local M = {}

local tools = {
  { package = "lua-language-server", executable = "lua-language-server", lsp = "lua_ls" },
  { package = "json-lsp", executable = "vscode-json-language-server", lsp = "jsonls" },
  { package = "yaml-language-server", executable = "yaml-language-server", lsp = "yamlls" },
  { package = "taplo", executable = "taplo", lsp = "taplo" },
  { package = "marksman", executable = "marksman", lsp = "marksman" },
  { package = "kube-linter", executable = "kube-linter" },
  { package = "yamlfmt", executable = "yamlfmt" },
  { package = "stylua", executable = "stylua" },
  { package = "prettierd", executable = "prettierd" },
  {
    package = "roslyn-language-server",
    executable = "roslyn-language-server",
    lsp = "roslyn_ls",
    automatic = false,
    condition = function()
      return vim.fn.executable("dotnet") == 1
    end,
  },
  {
    package = "csharpier",
    executable = "csharpier",
    condition = function()
      return vim.fn.executable("dotnet") == 1
    end,
  },
  {
    package = "gitlab-ci-ls",
    executable = "gitlab-ci-ls",
    managed = false,
    recovery = "Install it with the platform dependency script; use :ToolingInfo to recheck.",
  },
}

local by_package = {}
for _, tool in ipairs(tools) do
  by_package[tool.package] = tool
end

local ready_callbacks = {}

local function tool_enabled(tool)
  return not tool.condition or tool.condition()
end

local function get_tool(package)
  return assert(by_package[package], "Unknown managed tool: " .. package)
end

local function state(tool)
  if not tool_enabled(tool) then
    return "disabled"
  end
  if vim.fn.executable(tool.executable) == 1 then
    return "ready"
  end
  if tool.managed == false then
    return "not installed on PATH"
  end

  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    return "Mason is unavailable"
  end

  local package_ok, mason_package = pcall(registry.get_package, tool.package)
  if not package_ok then
    return "missing from the Mason registry"
  end
  if mason_package:is_installing() then
    return "installing"
  end
  if mason_package:is_installed() then
    return "installed, but its executable is unavailable"
  end
  return "not installed"
end

local function run_ready_callbacks()
  for package, callbacks in pairs(ready_callbacks) do
    if M.available(package) then
      for _, callback in ipairs(callbacks) do
        if not callback.called then
          callback.called = true
          vim.schedule(callback.fn)
        end
      end
    end
  end
end

function M.enabled(package)
  return tool_enabled(get_tool(package))
end

function M.mason_packages()
  local packages = {}
  for _, tool in ipairs(tools) do
    if tool.managed ~= false and tool_enabled(tool) then
      table.insert(packages, tool.package)
    end
  end
  return packages
end

function M.lsp_servers()
  local servers = {}
  for _, tool in ipairs(tools) do
    if tool.lsp and tool.automatic ~= false and tool_enabled(tool) then
      table.insert(servers, tool.lsp)
    end
  end
  return servers
end

function M.available(package)
  local tool = get_tool(package)
  return tool_enabled(tool) and vim.fn.executable(tool.executable) == 1
end

function M.require(package)
  local tool = get_tool(package)
  local current_state = state(tool)
  if current_state == "ready" then
    return true
  end

  vim.notify_once(
    string.format(
      "%s is %s. %s",
      tool.package,
      current_state,
      tool.recovery or "Run :MasonToolsInstall to retry; use :MasonLog for details."
    ),
    vim.log.levels.WARN,
    { title = "tooling" }
  )
  return false
end

function M.on_ready(package, callback)
  get_tool(package)
  ready_callbacks[package] = ready_callbacks[package] or {}
  table.insert(ready_callbacks[package], { fn = callback, called = false })
  run_ready_callbacks()
end

function M.check()
  local missing = {}
  for _, tool in ipairs(tools) do
    local current_state = state(tool)
    if tool.managed ~= false and current_state ~= "ready" and current_state ~= "disabled" then
      table.insert(missing, string.format("%s (%s)", tool.package, current_state))
    end
  end

  if #missing > 0 then
    vim.notify(
      "Toolchain incomplete:\n- "
        .. table.concat(missing, "\n- ")
        .. "\nRun :MasonToolsInstall to retry; use :MasonLog for details.",
      vim.log.levels.WARN,
      { title = "tooling" }
    )
  end
  return missing
end

function M.info()
  local lines = {}
  for _, tool in ipairs(tools) do
    table.insert(lines, string.format("%-28s %s", tool.package, state(tool)))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "tooling" })
end

function M.setup()
  local group = vim.api.nvim_create_augroup("managed_tooling", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MasonToolsUpdateCompleted",
    callback = function()
      run_ready_callbacks()
      M.check()
    end,
  })
  vim.api.nvim_create_user_command("ToolingInfo", M.info, { desc = "Show managed tool status" })
end

return M
