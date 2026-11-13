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
    { "<M-h>", "<cmd>TmuxNavigateLeft<CR>" },
    { "<M-j>", "<cmd>TmuxNavigateDown<CR>" },
    { "<M-k>", "<cmd>TmuxNavigateUp<CR>" },
    { "<M-l>", "<cmd>TmuxNavigateRight<CR>" },
  },
}

