local group = vim.api.nvim_create_augroup("user_config", { clear = true })

require("config.navigation").setup_highlight(group)
require("config.refcounts").setup()

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  -- Drop the cached statusline environment segment when the project files it
  -- is derived from change (see env_status in statusline.lua).
  pattern = { "go.mod", "pyproject.toml", "poetry.lock" },
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.b[buf] then
        vim.b[buf].env_status = nil
      end
    end
  end,
})

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
    -- Floating preview buffers (LSP hover) are exempt: they are read-only and
    -- rely on Treesitter markdown for concealing fences and highlighting
    -- fenced code blocks.
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(event.buf) and vim.bo[event.buf].filetype == "markdown" then
        local floating = false
        for _, win in ipairs(vim.fn.win_findbuf(event.buf)) do
          if vim.api.nvim_win_get_config(win).relative ~= "" then
            floating = true
            break
          end
        end
        if not floating then
          vim.treesitter.stop(event.buf)
        end
      end
    end)
  end,
})
