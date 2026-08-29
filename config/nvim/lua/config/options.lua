vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.signcolumn = "yes:1"
opt.numberwidth = 2
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 5
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.conceallevel = 0
opt.fillchars:append({ eob = " " })
opt.termguicolors = false
opt.selectmode = ""
opt.keymodel = ""

-- Keep movement and UI transitions immediate.
opt.smoothscroll = false
vim.g.loaded_matchparen = 1
