return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  opts = {
    format_on_save = false,
    formatters_by_ft = {
      json = { "prettierd", "prettier", stop_after_first = true },
      lua = { "stylua" },
      yaml = { "yamlfmt" },
    },
  },
}
