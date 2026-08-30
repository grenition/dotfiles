local formatters_by_ft = {
  json = { "prettierd", "prettier", stop_after_first = true },
  lua = { "stylua" },
  yaml = { "yamlfmt" },
}

if vim.fn.executable("dotnet") == 1 then
  formatters_by_ft.cs = { "csharpier" }
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
