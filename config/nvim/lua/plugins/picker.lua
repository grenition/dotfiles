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
    fzf_opts = { ["--header"] = "enter: select   ctrl-s/v/t: split/vsplit/tab   alt-q: quickfix   esc: cancel" },
    lsp = { code_actions = { previewer = false } },
  },
}
