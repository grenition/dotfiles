---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    default_component_configs = {
      symlink_target = { enabled = true },
    },
    filesystem = {
      window = {
        mappings = {
          -- both spellings override the default "<esc>" = "cancel"
          ["<Esc>"] = { function() vim.cmd.wincmd "p" end, desc = "Jump back to code" },
          ["<esc>"] = { function() vim.cmd.wincmd "p" end, desc = "Jump back to code" },
        },
      },
    },
    buffers = {
      window = {
        mappings = {
          ["<Esc>"] = { function() vim.cmd.wincmd "p" end, desc = "Jump back to code" },
          ["<esc>"] = { function() vim.cmd.wincmd "p" end, desc = "Jump back to code" },
        },
      },
    },
    git_status = {
      window = {
        mappings = {
          ["<Esc>"] = { function() vim.cmd.wincmd "p" end, desc = "Jump back to code" },
          ["<esc>"] = { function() vim.cmd.wincmd "p" end, desc = "Jump back to code" },
        },
      },
    },
  },
}
