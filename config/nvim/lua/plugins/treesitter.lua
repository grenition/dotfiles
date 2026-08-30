local parsers = { "bash", "json", "lua", "markdown", "toml", "vim", "yaml" }

if vim.fn.executable("dotnet") == 1 then
  table.insert(parsers, "c_sharp")
end

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  opts = {
    parser_install_dir = vim.fn.stdpath("data") .. "/site",
    ensure_installed = parsers,
    -- Neovim 0.12.5 crashes its own Treesitter decoration provider on fenced
    -- Markdown blocks. Keep Treesitter everywhere else and use Vim syntax for
    -- Markdown until the upstream runtime bug is fixed.
    highlight = { enable = true, disable = { "markdown" } },
    indent = { enable = true },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
