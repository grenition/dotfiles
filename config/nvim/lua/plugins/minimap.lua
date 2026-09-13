return {
  "gorbit99/codewindow.nvim",
  -- Upstream is unmaintained and imports the legacy nvim-treesitter.ts_utils
  -- module, which the nvim-treesitter master rewrite removed. Verified against
  -- the locked commit a8e1750: only get_vim_range is used, and converting the
  -- 0-based treesitter range to 1-based indices is sufficient for minimap
  -- highlighting. Shim the module via package.preload before plugin load.
  init = function()
    package.preload["nvim-treesitter.ts_utils"] = function()
      return {
        get_vim_range = function(range)
          return range[1] + 1, range[2] + 1, range[3] + 1, range[4] + 1
        end,
      }
    end
  end,
  -- Eager load: the config.minimap controller wires its BufWinEnter autocmd
  -- during setup, so it must run before the first buffer is entered.
  lazy = false,
  keys = {
    {
      "<leader>um",
      function()
        require("config.minimap").toggle()
      end,
      desc = "Minimap",
    },
  },
  opts = {
    -- The config.minimap controller owns opening and closing; auto_enable
    -- reopens the minimap unconditionally and would fight its width rule.
    auto_enable = false,
    minimap_width = 12,
    window_border = "none",
    exclude_filetypes = { "help", "neo-tree", "fzf", "qf" },
  },
  config = function(_, opts)
    require("codewindow").setup(opts)
    require("config.minimap").setup()
  end,
}
