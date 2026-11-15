---@type LazySpec
return {
  "christoomey/vim-tmux-navigator",
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
  },
  keys = {
    { "<M-h>", function() vim.cmd.TmuxNavigateLeft() end },
    { "<M-j>", function() vim.cmd.TmuxNavigateDown() end },
    { "<M-k>", function() vim.cmd.TmuxNavigateUp() end },
    { "<M-l>", function() vim.cmd.TmuxNavigateRight() end },
  },
}

