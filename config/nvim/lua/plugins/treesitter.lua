local parsers = { "bash", "go", "json", "lua", "markdown", "markdown_inline", "python", "toml", "vim", "yaml" }

if vim.fn.executable("dotnet") == 1 then
  table.insert(parsers, "c_sharp")
end

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  opts = {
    install_dir = vim.fn.stdpath("data") .. "/site",
    ensure_installed = parsers,
  },
  config = function(_, opts)
    local ts = require("nvim-treesitter")
    ts.setup({ install_dir = opts.install_dir })

    -- Install only parsers whose .so is missing, never to sync revisions:
    -- rewriting a .so under open sessions makes macOS kill any process that
    -- dlopens it mid-copy (EXC_BAD_ACCESS, invalid code page), and concurrent
    -- installs corrupt the file outright. Revision updates are left to an
    -- explicit :TSUpdate. A cache lock keeps parallel nvim starts (tmux
    -- session restore) from racing on the same parser files.
    if vim.env.NVIM_CONFIG_CHECK ~= "1" and vim.fn.executable("tree-sitter") == 1 then
      local missing = {}
      for _, lang in ipairs(opts.ensure_installed) do
        if vim.uv.fs_stat(opts.install_dir .. "/parser/" .. lang .. ".so") == nil then
          table.insert(missing, lang)
        end
      end

      if #missing > 0 then
        local lock = vim.fn.stdpath("cache") .. "/nvim-treesitter-install.lock"
        local stolen = false
        local handle = vim.uv.fs_open(lock, "wx", 438)
        if not handle then
          local stat = vim.uv.fs_stat(lock)
          stolen = stat and (os.time() - stat.mtime.sec) > 600
          if stolen then
            os.remove(lock)
            handle = vim.uv.fs_open(lock, "wx", 438)
          end
        end
        if handle then
          vim.uv.fs_close(handle)
          vim.api.nvim_create_autocmd("VimLeavePre", {
            callback = function()
              os.remove(lock)
            end,
          })
          ts.install(missing)
        end
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        -- Neovim 0.12.5 crashes its own Treesitter decoration provider on
        -- fenced Markdown blocks. Keep Treesitter everywhere else and use
        -- Vim syntax for Markdown until the upstream runtime bug is fixed.
        if args.match == "markdown" then
          return
        end
        -- Treesitter is used for highlighting only: its indentexpr drops
        -- the inherited indentation on new lines in several grammars, so
        -- indentation is handled by autoindent/smartindent/copyindent in
        -- config/options.lua.
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
