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
      ["--bind"] = "j:down,k:up,J:down+down+down+down+down+down+down+down+down+down,K:up+up+up+up+up+up+up+up+up+up",
    },
    winopts = {
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
