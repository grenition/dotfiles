local default_servers = { "lua_ls", "jsonls", "yamlls", "taplo" }
local installed_servers = vim.deepcopy(default_servers)

if vim.fn.executable("dotnet") == 1 then
  table.insert(installed_servers, "roslyn_ls")
end

return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
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
      local lsp_ui = require("config.lsp_ui")

      local function roslyn_command()
        local registry = require("mason-registry")
        local package = registry.get_package("roslyn-language-server")
        if not package:is_installed() then
          return nil
        end

        -- Mason's global-tool launcher misdetects Homebrew's DOTNET_ROOT on macOS.
        -- Launch the server binary inside the package instead. Mason 2 removed
        -- Package:get_install_path(), so resolve its default package directory.
        local executable = vim.fs.find("Microsoft.CodeAnalysis.LanguageServer", {
          path = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", package.name),
          limit = 1,
        })[1]
        if executable and vim.fn.executable(executable) == 1 then
          return {
            executable,
            "--logLevel",
            "Information",
            "--extensionLogDirectory",
            vim.fs.joinpath(vim.fn.stdpath("cache"), "roslyn_ls", "logs"),
            "--stdio",
          }
        end
      end

      local function enable_roslyn()
        local command = roslyn_command()
        if not command then
          return
        end

        vim.lsp.config("roslyn_ls", {
          cmd = command,
          cmd_env = dotnet.env(),
        })
        vim.lsp.enable("roslyn_ls")
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
      if vim.fn.executable("gitlab-ci-ls") == 1 then
        local cache_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "gitlab-ci-ls")
        local log_dir = vim.fs.joinpath(cache_dir, "log")
        vim.fn.mkdir(log_dir, "p")
        vim.fn.mkdir(vim.fs.joinpath(cache_dir, "base"), "p")
        vim.lsp.config("gitlab_ci_ls", {
          -- A project marker is more reliable than guessing a YAML dialect
          -- from arbitrary template filenames such as AndroidTemplate.yml.
          filetypes = { "yaml", "yaml.gitlab" },
          root_dir = function(bufnr, on_dir)
            local template_root = vim.fs.root(bufnr, { ".gitlab-ci-ls.yml" })
            if template_root then
              on_dir(template_root)
              return
            end

            local filename = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
            if filename == ".gitlab-ci.yml" or filename == ".gitlab-ci.yaml" then
              on_dir(vim.fs.root(bufnr, { ".git" }) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
            end
          end,
          init_options = {
            -- gitlab-ci-ls 1.4 uses `cache`; keep `cache_path` for older
            -- releases supported by nvim-lspconfig.
            cache = cache_dir .. "/",
            cache_path = cache_dir .. "/",
            log_path = vim.fs.joinpath(log_dir, "gitlab-ci-ls.log"),
          },
        })
        vim.lsp.enable("gitlab_ci_ls")
      end
      if vim.fn.executable("dotnet") == 1 then
        enable_roslyn()

        -- mason-lspconfig installs Roslyn asynchronously on the first start.
        -- Enable it as soon as that installation finishes, without requiring a
        -- second Neovim restart.
        require("mason-registry"):on("package:install:success", function(package)
          if package.name == "roslyn-language-server" then
            vim.schedule(enable_roslyn)
          end
        end)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("roslyn_ide_features", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "roslyn_ls" then
            return
          end

          if client.server_capabilities.inlayHintProvider then
            lsp_ui.apply_inlay_hints(args.buf)
          end

          if client.server_capabilities.codeLensProvider then
            lsp_ui.apply_code_lenses(args.buf)
          end
        end,
      })
      vim.lsp.config("yamlls", {
        on_init = function(client)
          local root = client.root_dir
          if not root or not vim.uv.fs_stat(vim.fs.joinpath(root, ".gitlab-ci-ls.yml")) then
            return
          end

          -- Every YAML document in an explicitly marked template repository is
          -- GitLab CI. Standard .gitlab-ci.yml files are detected by SchemaStore.
          client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
            yaml = {
              schemas = {
                ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = {
                  "**/*.yml",
                  "**/*.yaml",
                },
              },
            },
          })
        end,
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
        ensure_installed = vim.env.NVIM_CONFIG_CHECK == "1" and {} or installed_servers,
        automatic_enable = default_servers,
      })
    end,
  },
}
