---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    opts = {
      colorscheme = "astrotheme",
    },
  },
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    opts = {
      update_interval = 3000,
    },
  },
}
