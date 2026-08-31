local group = vim.api.nvim_create_augroup("user_config", { clear = true })

-- gitlab-ci-ls intentionally attaches only to yaml.gitlab. Keep yamlls on the
-- same buffers for YAML syntax/schema support while enabling GitLab-aware
-- navigation and refactors for both conventional pipelines and template repos.
vim.filetype.add({
  filename = {
    [".gitlab-ci.yml"] = "yaml.gitlab",
    [".gitlab-ci.yaml"] = "yaml.gitlab",
  },
  pattern = {
    [".*%.gitlab%-ci%.yml"] = { "yaml.gitlab", { priority = 1000 } },
    [".*%.gitlab%-ci%.yaml"] = { "yaml.gitlab", { priority = 1000 } },
    [".*/%.gitlab/ci/.*%.yml"] = { "yaml.gitlab", { priority = 1000 } },
    [".*/%.gitlab/ci/.*%.yaml"] = { "yaml.gitlab", { priority = 1000 } },
    [".*/gitlab/ci/.*%.yml"] = { "yaml.gitlab", { priority = 1000 } },
    [".*/gitlab/ci/.*%.yaml"] = { "yaml.gitlab", { priority = 1000 } },
  },
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
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(event.buf) and vim.bo[event.buf].filetype == "markdown" then
        vim.treesitter.stop(event.buf)
      end
    end)
  end,
})
