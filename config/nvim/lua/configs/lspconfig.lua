local nvlsp = require("nvchad.configs.lspconfig")
local lspconfig = require("lspconfig")

local servers = { "html", "cssls" }

for _, srv in ipairs(servers) do
  lspconfig[srv].setup {
    on_attach = nvlsp.on_attach,
    capabilities = nvlsp.capabilities,
  }
end

local pid = vim.fn.getpid()

lspconfig.omnisharp.setup {
  cmd         = { "omnisharp", "--languageserver", "--hostPID", tostring(pid) },
  on_attach   = nvlsp.on_attach,
  capabilities= nvlsp.capabilities,
}
