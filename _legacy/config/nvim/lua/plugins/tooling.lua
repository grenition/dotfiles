local tooling = require("config.tooling")

return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = tooling.mason_packages(),
      run_on_start = vim.env.NVIM_CONFIG_CHECK ~= "1",
      integrations = {
        ["mason-lspconfig"] = false,
        ["mason-null-ls"] = false,
        ["mason-nvim-dap"] = false,
      },
    },
    config = function(_, opts)
      tooling.setup()
      require("mason-tool-installer").setup(opts)
    end,
  },
}
