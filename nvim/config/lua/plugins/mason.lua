-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "lua-language-server",
        "yaml-language-server",
        "gitlab-ci-ls",
        "roslyn-language-server",
        "terraform-ls",
        "ansible-language-server",

        -- install linters
        "tflint",
        "ansible-lint",

        -- install formatters
        "csharpier",
        "prettier",

        -- install debuggers
        "netcoredbg",
      },
    },
  },
}
