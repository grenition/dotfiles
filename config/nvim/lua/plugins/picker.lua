return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  event = "VimEnter",
  opts = {
    "default",
    ui_select = function(_, items)
      local rows = math.max(#items + 4, 8)
      local h = math.min(rows / vim.o.lines, 0.70)
      return { winopts = { height = h, width = 0.70, row = 0.40 } }
    end,
    fzf_opts = {
      ["--header"] = "enter: select   ctrl-s/v/t: split/vsplit/tab   alt-q: quickfix   esc: cancel   j/k/J/K: nav   ctrl-j/k: preview",
    },
    -- fzf-lua (rev 05e44d3) always rewrites fzf_opts["--bind"] from its
    -- keymap tables (core.lua:651), so raw j/k/J/K nav binds go through
    -- `fzf_cli_args` (documented string, config.lua:465), which core.lua:720-730
    -- appends verbatim after fzf_opts; fzf accumulates repeated --bind flags.
    fzf_cli_args = "--bind=j:down,k:up,J:down+down+down+down+down+down+down+down+down+down,K:up+up+up+up+up+up+up+up+up+up",
    winopts = {
      -- fzf-lua.win:preview_scroll is internal (verified against locked rev 05e44d3):
      -- the builtin previewer only scrolls 1 line per action with a fixed step,
      -- so the tmap repeats the same funcref fzf-lua dispatches for keymap.builtin.
      on_create = function()
        local rhs = function(fnc)
          return ("<Cmd>lua require('fzf-lua.win').%s<CR>"):format(fnc):rep(10)
        end
        local opts = { buffer = true, nowait = true, silent = true }
        vim.keymap.set("t", "<C-j>", rhs("preview_scroll('line-down')"), opts)
        vim.keymap.set("t", "<C-k>", rhs("preview_scroll('line-up')"), opts)
      end,
    },
    lsp = { code_actions = { previewer = false } },
  },
}
