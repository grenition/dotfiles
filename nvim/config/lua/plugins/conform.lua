---@type LazySpec
return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<Leader>lf",
      function() require("conform").format { async = true, lsp_fallback = true, timeout_ms = 3000 } end,
      desc = "Format buffer",
      mode = { "n", "v" },
    },
  },
  opts = {
    format_on_save = function(bufnr)
      if vim.bo[bufnr].filetype == "cs" then return end -- csharpier: manual only, <Leader>lf
      return { timeout_ms = 3000, lsp_format = "fallback" } -- LSP if no formatter configured (gopls, terraform-ls, ...)
    end,
    -- binaries come from Mason (mason-tool-installer): stylua, csharpier, prettier, goimports, ruff
    formatters_by_ft = {
      lua = { "stylua" },
      go = { "goimports", "gofmt" },
      python = { "ruff_format" },
      cs = { "csharpier" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      ["markdown.mdx"] = { "prettier" },
      graphql = { "prettier" },
      handlebars = { "prettier" },
    },
  },
}
