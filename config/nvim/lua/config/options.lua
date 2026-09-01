vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.mousemoveevent = true
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.signcolumn = "yes:1"
opt.numberwidth = 2
opt.updatetime = 250
opt.timeoutlen = 100
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 5
opt.sidescrolloff = 8
opt.wrap = false
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.conceallevel = 0
opt.fillchars:append({ eob = " " })
opt.termguicolors = false
opt.selectmode = ""
opt.keymodel = ""

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  virtual_text = {
    prefix = "●",
    source = "if_many",
    spacing = 2,
    format = function(diagnostic)
      return diagnostic.code and tostring(diagnostic.code) or diagnostic.message
    end,
  },
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "󰌵",
    },
  },
})

-- Keep movement and UI transitions immediate.
opt.smoothscroll = false
vim.g.loaded_matchparen = 1
