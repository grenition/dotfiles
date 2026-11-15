---@type LazySpec
return {
  "ajbucci/ipynb.nvim",
  enabled = vim.env.NVIM_ENABLE_IPYNB == "true",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "neovim/nvim-lspconfig",
    "nvim-tree/nvim-web-devicons",
    "folke/snacks.nvim"
  },
  opts = {},
}
