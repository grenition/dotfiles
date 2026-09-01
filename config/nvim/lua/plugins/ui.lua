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
        close_command = function(buffer)
          require("config.buffers").close(buffer)
        end,
        middle_mouse_command = function(buffer)
          require("config.buffers").close(buffer)
        end,
        custom_filter = require("config.buffers").show_in_bufferline,
        color_icons = false,
        get_element_icon = function(element)
          local name = not element.directory
              and require("config.gitlab").is_ci_file(element.path)
              and ".gitlab-ci.yml"
            or vim.fs.basename(element.path)
          local icon = require("nvim-web-devicons").get_icon(name, element.extension, { default = true })

          -- Returning no icon highlight makes it inherit the exact tab
          -- background, including the transparent terminal theme.
          return icon or ""
        end,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diagnostics)
          if diagnostics.error and diagnostics.error > 0 then
            return string.format("  %d", diagnostics.error)
          end
          if diagnostics.warning and diagnostics.warning > 0 then
            return string.format("  %d", diagnostics.warning)
          end
          return ""
        end,
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        left_trunc_marker = "󰁍",
        right_trunc_marker = "󰁔",
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "thin",
        indicator = { style = "none" },
        tab_size = 12,
        max_name_length = 30,
        max_prefix_length = 18,
        sort_by = "insert_after_current",
        persist_buffer_sort = true,
        offsets = {
          {
            filetype = "neo-tree",
            text = "  EXPLORER",
            text_align = "left",
            separator = true,
          },
        },
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
