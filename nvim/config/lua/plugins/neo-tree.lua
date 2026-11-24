---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    source_selector = {
      winbar = false,
      separator = "",
      sources = {
        { source = "filesystem", display_name = "Files" },
        { source = "buffers", display_name = "Buffers" },
        { source = "git_status", display_name = "Git" },
      },
    },
    default_component_configs = {
      symlink_target = { enabled = true },
      file_size = { enabled = false },
      type = { enabled = false },
      last_modified = { enabled = false },
      created = { enabled = false },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
      },
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
