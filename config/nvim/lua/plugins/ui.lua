return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      terminal_colors = true,
    },
  },
  {
    "akinsho/bufferline.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        get_element_icon = function(element)
          if not element.directory and require("config.gitlab").is_ci_file(element.path) then
            return require("nvim-web-devicons").get_icon(".gitlab-ci.yml")
          end
        end,
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
    event = "VeryLazy",
    opts = {
      delay = 400,
    },
  },
}
