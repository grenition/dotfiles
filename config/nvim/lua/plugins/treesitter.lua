local parsers = { "bash", "json", "lua", "markdown", "toml", "vim", "yaml" }

if vim.fn.executable("dotnet") == 1 then
  table.insert(parsers, "c_sharp")
end

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  opts = {
    install_dir = vim.fn.stdpath("data") .. "/site",
    ensure_installed = parsers,
  },
  config = function(_, opts)
    local ts = require("nvim-treesitter")
    ts.setup({ install_dir = opts.install_dir })
    ts.install(opts.ensure_installed)

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        -- Neovim 0.12.5 crashes its own Treesitter decoration provider on
        -- fenced Markdown blocks. Keep Treesitter everywhere else and use
        -- Vim syntax for Markdown until the upstream runtime bug is fixed.
        if args.match == "markdown" then
          return
        end
        if pcall(vim.treesitter.start) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
