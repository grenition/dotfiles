local group = vim.api.nvim_create_augroup("user_config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = group,
  pattern = { "Makefile", "makefile", "*.mk" },
  callback = function()
    vim.opt_local.expandtab = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "markdown",
  callback = function(event)
    -- Some plugins can start Neovim's highlighter after the Treesitter module
    -- has declined Markdown. Stop it at the end of the FileType event: this
    -- avoids the 0.12.5 fenced-code-block crash while keeping regex syntax.
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(event.buf) and vim.bo[event.buf].filetype == "markdown" then
        vim.treesitter.stop(event.buf)
      end
    end)
  end,
})
