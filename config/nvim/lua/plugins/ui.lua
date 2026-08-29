return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "akinsho/bufferline.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = "thin",
        indicator = { style = "underline" },
        tab_size = 18,
        max_name_length = 18,
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      require("config.theme").apply_ui_highlights()
    end,
  },
  {
    "folke/which-key.nvim",
    lazy = false,
    opts = {
      delay = 400,
    },
  },
}
