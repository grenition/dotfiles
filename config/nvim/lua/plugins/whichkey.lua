-- Which-key adds a discoverable menu for the <leader> mappings defined in
-- lua/config/keymaps.lua. This spec only labels existing prefixes; every
-- mapping description already comes from keymaps.lua.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    icons = {
      -- Plain text labels; avoid the mini.icons/nvim-web-devicons dependency.
      mappings = false,
    },
    -- Group labels for multi-key <leader> prefixes. Leaf mappings
    -- (<leader>ff, <leader>ud, <leader>ol, ...) keep their own descs.
    spec = {
      { "<leader>b", group = "Buffers" },
      { "<leader>f", group = "Search" },
      { "<leader>o", group = "Code" },
      { "<leader>u", group = "UI" },
      { "<leader>g", group = "Git" },
    },
  },
}
