local formatters_by_ft = {
  json = { "prettierd", "prettier", stop_after_first = true },
  lua = { "stylua" },
  yaml = { "yamlfmt" },
}

if vim.fn.executable("dotnet") == 1 then
  formatters_by_ft.cs = { "csharpier" }
end

-- gofmt ships with the Go toolchain itself; goimports is declared in tooling.lua.
if vim.fn.executable("go") == 1 then
  formatters_by_ft.go = { "goimports", "gofmt", stop_after_first = true }
end

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  opts = {
    format_on_save = false,
    formatters = {
      csharpier = { env = require("config.dotnet").env },
    },
    formatters_by_ft = formatters_by_ft,
  },
}
