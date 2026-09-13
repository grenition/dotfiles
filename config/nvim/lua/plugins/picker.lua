return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  opts = {
    "default",
    ui_select = function(_, items)
      local min_h, max_h = 0.15, 0.70
      local h = (#items + 4) / vim.o.lines
      if h < min_h then
        h = min_h
      elseif h > max_h then
        h = max_h
      end
      return { winopts = { height = h, width = 0.60, row = 0.40 } }
    end,
    fzf_opts = { ["--header"] = "enter: select   ctrl-s/v/t: split/vsplit/tab   alt-q: quickfix   esc: cancel" },
  },
}
