return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    opts = {
      override_by_extension = {
        yaml = { icon = "󱃾", color = "#326CE5", cterm_color = "33", name = "KubernetesYaml" },
        yml = { icon = "󱃾", color = "#326CE5", cterm_color = "33", name = "KubernetesYaml" },
      },
    },
  },
  {
    "akinsho/bufferline.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and "" or ""
          return string.format(" %s %d", icon, count)
        end,
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
