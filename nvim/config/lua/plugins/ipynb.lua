---@type LazySpec
return {
  "ajbucci/ipynb.nvim",
  enabled = vim.env.NVIM_ENABLE_IPYNB == "true",
  lazy = false,
  keys = {
    { "<leader>kA", "<cmd>NotebookExecuteAll<CR>", mode = "n", desc = "Run all notebook cells" },
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "neovim/nvim-lspconfig",
    "nvim-tree/nvim-web-devicons",
    "folke/snacks.nvim"
  },
  opts = {},
}
