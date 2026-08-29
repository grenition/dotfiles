-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.scrolloff = 5
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Let the terminal own the palette. With true color disabled, Neovim uses the
-- terminal's ANSI colors instead of rendering a separate GUI colorscheme.
vim.opt.termguicolors = false
vim.opt.winblend = 0
vim.opt.pumblend = 0

-- Keep every movement and UI transition immediate.
vim.opt.smoothscroll = false
vim.g.snacks_animate = false

-- The built-in matchparen plugin can spend up to 300 ms searching for a pair
-- on large or minified lines. Disable it to keep cursor movement immediate.
vim.g.loaded_matchparen = 1

-- IDEA-only options removed:
-- ideajoin, ideastatusicon, ideamarks, highlightedyank, NERDTree, which-key
-- timeout behavior (у тебя было set notimeout + timeoutlen=5000)
vim.opt.timeout = false
vim.opt.timeoutlen = 5000
