return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "lua_ls", "jsonls", "yamlls", "taplo" },
      automatic_enable = { "lua_ls", "jsonls", "yamlls", "taplo" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local dotnet = require("config.dotnet")

      local function roslyn_command()
        local registry = require("mason-registry")
        local package = registry.get_package("roslyn-language-server")
        if not package:is_installed() then
          return nil
        end

        -- Mason's global-tool launcher misdetects Homebrew's DOTNET_ROOT on macOS.
        -- Launch the server binary inside the package instead.
        local executable = vim.fs.find("Microsoft.CodeAnalysis.LanguageServer", {
          path = package:get_install_path(),
          limit = 1,
        })[1]
        if executable and vim.fn.executable(executable) == 1 then
          return { executable, "--stdio" }
        end
      end

      vim.lsp.config("*", { capabilities = capabilities })
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            diagnostics = { globals = { "vim" } },
          },
        },
      })
      if vim.fn.executable("dotnet") == 1 then
        local command = roslyn_command()
        if command then
          vim.lsp.config("roslyn_ls", {
            cmd = command,
            cmd_env = dotnet.env(),
          })
          vim.lsp.enable("roslyn_ls")
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("roslyn_ide_features", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "roslyn_ls" then
            return
          end

          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end

          if client.server_capabilities.codeLensProvider then
            vim.lsp.codelens.enable(true, { bufnr = args.buf })
          end
        end,
      })
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            -- Let yamlfmt handle formatting so formatting is consistent between
            -- Neovim and CI.  yamlls still provides completion and validation.
            format = { enable = false },
            keyOrdering = false,
            kubernetesCRDStore = { enable = true },
            schemaStore = { enable = true },
            schemas = {
              kubernetes = {
                "k8s/**/*.yaml",
                "k8s/**/*.yml",
                "kubernetes/**/*.yaml",
                "kubernetes/**/*.yml",
                "manifests/**/*.yaml",
                "manifests/**/*.yml",
                "*.k8s.yaml",
                "*.k8s.yml",
                "*.kubernetes.yaml",
                "*.kubernetes.yml",
              },
            },
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "jsonls", "yamlls", "taplo" },
        automatic_enable = { "lua_ls", "jsonls", "yamlls", "taplo" },
      })
    end,
  },
}
