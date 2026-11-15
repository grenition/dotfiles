---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    indent = {
      enabled = true,
      indent = { char = "·" },
      scope = { char = "·" },
    },
    picker = {
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "i", "n" } },
            ["q"] = { "close", mode = { "i", "n" } },
            ["j"] = { "list_down", mode = { "i", "n" } },
            ["k"] = { "list_up", mode = { "i", "n" } }
          },
        },
      },
    },
  },
}
