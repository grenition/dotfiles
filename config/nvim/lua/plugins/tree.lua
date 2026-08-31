local preview = require("config.neo_tree_preview")

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    log_to_file = false,
    close_if_last_window = true,
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          -- JetBrains-style preview: entering the project tree starts a
          -- non-floating preview in the editor.
          vim.schedule(preview.show_selected)
        end,
      },
      {
        event = "vim_cursor_moved",
        handler = preview.show_selected,
      },
      {
        event = "neo_tree_buffer_leave",
        handler = function()
          preview.hide()
        end,
      },
      {
        event = "file_opened",
        handler = preview.pin,
      },
    },
    default_component_configs = {
      icon = {
        provider = function(icon, node)
          if node.type ~= "file" and node.type ~= "terminal" then
            return
          end

          local name = node.type == "terminal" and "terminal" or node.name
          if node.type == "file" and require("config.gitlab").is_ci_file(node.path) then
            name = ".gitlab-ci.yml"
          end

          local devicon, highlight = require("nvim-web-devicons").get_icon(name)
          icon.text = devicon or icon.text
          icon.highlight = highlight or icon.highlight
        end,
      },
      git_status = {
        symbols = {
          added = "+",
          deleted = "-",
          modified = "~",
          renamed = "→",
          untracked = "+",
          ignored = "○",
          unstaged = "~",
          staged = "✓",
          conflict = "!",
        },
      },
    },
    filesystem = {
      -- Keep the tree cursor under user control. Files opened via search,
      -- buffer tabs, LSP jumps, etc. must not reveal themselves implicitly.
      follow_current_file = { enabled = false },
      hijack_netrw_behavior = "open_default",
      use_libuv_file_watcher = vim.env.NVIM_CONFIG_CHECK ~= "1",
    },
    window = {
      width = 26,
      mappings = {
        ["h"] = "close_node",
        ["l"] = "open",
        ["j"] = function()
          vim.cmd.normal({ args = { "j" }, bang = true })
        end,
        ["k"] = function()
          vim.cmd.normal({ args = { "k" }, bang = true })
        end,
        ["x"] = "cut_to_clipboard",
        ["y"] = "copy_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["P"] = {
          "toggle_preview",
          config = preview.options,
        },
      },
    },
  },
}
