vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.swapfile = false
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.signcolumn = "yes:1"
opt.numberwidth = 2
opt.updatetime = 250
opt.timeoutlen = 100
opt.splitright = true
opt.splitbelow = true
-- One statusline shared by every window; lualine's globalstatus builds on it.
opt.laststatus = 3
opt.scrolloff = 5
opt.sidescrolloff = 8
-- Hide the command/message line while it is idle; Neovim reveals it on demand.
opt.cmdheight = 0
opt.wrap = false
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
-- Keep the previous line's indentation on Enter/o/O (copyindent preserves
-- literal tabs, e.g. in Makefiles) and add a level after { / drop it on }.
opt.autoindent = true
opt.smartindent = true
opt.copyindent = true
opt.conceallevel = 0
opt.fillchars:append({ eob = " " })
opt.termguicolors = false
-- Never request a blinking cursor; the steady look is set in Ghostty.
opt.guicursor:append("a:blinkon0")

-- Shift+arrows (with any modifier combo) start a native Select-mode
-- selection that typing replaces, like in a regular editor.
opt.keymodel = "startsel,stopsel"
opt.selectmode = "key"

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
