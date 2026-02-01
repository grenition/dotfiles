-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.scrolloff = 5

-- IDEA-only options removed:
-- ideajoin, ideastatusicon, ideamarks, highlightedyank, NERDTree, which-key
-- timeout behavior (у тебя было set notimeout + timeoutlen=5000)
vim.opt.timeout = false
vim.opt.timeoutlen = 5000
