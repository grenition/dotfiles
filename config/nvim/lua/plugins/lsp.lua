return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "lua_ls", "jsonls", "yamlls", "taplo" },
      automatic_enable = { "lua_ls", "jsonls", "yamlls", "taplo" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("*", { capabilities = capabilities })
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            diagnostics = { globals = { "vim" } },
          },
        },
      })
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            -- Let yamlfmt handle formatting so formatting is consistent between
            -- Neovim and CI.  yamlls still provides completion and validation.
            format = { enable = false },
            keyOrdering = false,
            kubernetesCRDStore = { enable = true },
            schemaStore = { enable = true },
            schemas = {
              kubernetes = {
                "k8s/**/*.yaml",
                "k8s/**/*.yml",
                "kubernetes/**/*.yaml",
                "kubernetes/**/*.yml",
                "manifests/**/*.yaml",
                "manifests/**/*.yml",
                "*.k8s.yaml",
                "*.k8s.yml",
                "*.kubernetes.yaml",
                "*.kubernetes.yml",
              },
            },
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "jsonls", "yamlls", "taplo" },
        automatic_enable = { "lua_ls", "jsonls", "yamlls", "taplo" },
      })
    end,
  },
}
