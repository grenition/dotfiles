return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    lazy = false,
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
    },
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    lazy = false,
    config = function()
      local rainbow = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow.strategy["global"],
          vim = rainbow.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local function textobject(query)
        return function()
          select.select_textobject(query, "textobjects")
        end
      end

      for lhs, query in pairs({
        af = "@function.outer",
        ["if"] = "@function.inner",
        ac = "@class.outer",
        ic = "@class.inner",
        ab = "@block.outer",
        ib = "@block.inner",
      }) do
        vim.keymap.set({ "x", "o" }, lhs, textobject(query), { desc = "Treesitter " .. query })
      end
    end,
  },
}
