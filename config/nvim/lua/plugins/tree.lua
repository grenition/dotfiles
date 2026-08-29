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
    close_if_last_window = true,
    filesystem = {
      follow_current_file = { enabled = true },
      hijack_netrw_behavior = "open_default",
      use_libuv_file_watcher = true,
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
      },
    },
  },
}
