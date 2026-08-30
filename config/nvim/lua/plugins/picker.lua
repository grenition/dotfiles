local function setup_modal_navigation(event)
  local function send_to_fzf(bytes)
    return function()
      local channel = vim.bo[event.bufnr].channel
      if channel > 0 then
        vim.api.nvim_chan_send(channel, bytes)
      end
    end
  end

  local opts = { buffer = event.bufnr, nowait = true, silent = true }
  vim.keymap.set("n", "h", send_to_fzf("\27[D"), opts)
  vim.keymap.set("n", "j", send_to_fzf("\27[B"), opts)
  vim.keymap.set("n", "k", send_to_fzf("\27[A"), opts)
  vim.keymap.set("n", "l", send_to_fzf("\27[C"), opts)
  vim.keymap.set("n", "<CR>", send_to_fzf("\r"), opts)
  vim.keymap.set("n", "<Esc>", send_to_fzf("\27"), opts)
  vim.keymap.set("n", "q", send_to_fzf("\27"), opts)
  vim.keymap.set("n", "i", function() vim.cmd.startinsert() end, opts)
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)

  -- fzf-lua enters Terminal mode after creating the window; switch it back
  -- on the next event-loop tick so a picker always opens in Normal mode.
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(event.bufnr) then vim.cmd.stopinsert() end
  end)
end

return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  opts = {
    "default",
    winopts = { on_create = setup_modal_navigation },
  },
}
