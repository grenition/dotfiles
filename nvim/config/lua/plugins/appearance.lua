return {
  {
    "AstroNvim/astroui",
    opts = {
      colorscheme = "workspace",
      status = {
        separators = { left = { " ", " " }, right = { " ", " " } },
        components = {
          mode = { surround = { condition = function() return false end } },
          nav = { scrollbar = false },
        },
        colors = function(colors)
          local c = require("workspace.palette")[vim.o.background]
          for name in pairs(colors) do
            if name:match("_bg$") then colors[name] = c.panel end
            if name:match("_fg$") then colors[name] = c.fg end
          end
          colors.bg, colors.fg = c.panel, c.fg
          for _, mode in ipairs { "normal", "insert", "visual", "replace", "command", "terminal", "inactive" } do
            colors[mode] = c.selection
          end
          colors.buffer_active_bg, colors.buffer_active_fg = c.bg, c.accent
          colors.git_branch_fg, colors.file_info_fg = c.muted, c.fg
          colors.lsp_fg, colors.treesitter_fg, colors.nav_fg = c.muted, c.muted, c.muted
          colors.git_added, colors.git_changed, colors.git_removed = c.success, c.warning, c.error
          colors.diag_ERROR, colors.diag_WARN = c.error, c.warning
          colors.diag_INFO, colors.diag_HINT = c.accent, c.accent
          return colors
        end,
      },
    },
  },
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      opts.tabline[1].provider = function(self)
        if vim.bo[vim.api.nvim_win_get_buf(self.winid)].filetype == "neo-tree" then
          local state = require("neo-tree.sources.manager").get_state_for_window(self.winid)
          if state then return require("neo-tree.ui.selector").get_selector(state, self.winwidth) .. " " end
        end
        return (" "):rep(self.winwidth + 1)
      end
    end,
  },
  { "AstroNvim/astrotheme", enabled = false },
  {
    "nvim-mini/mini.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("mini.animate").setup {
        cursor = {
          enable = true,
          timing = function() return 12 end,
        },
        scroll = { enable = false },
      }
    end,
  },
}
