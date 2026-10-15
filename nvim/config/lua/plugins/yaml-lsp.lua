---@type LazySpec
return {
  "AstroNvim/astrolsp",
  opts = {
    config = {
      gitlab_ci_ls = {
        handlers = {
          ["textDocument/publishDiagnostics"] = function(err, result, ctx)
            if result and result.diagnostics then
              result.diagnostics = vim.tbl_filter(function(d)
                return not (d.message or ""):match("^Stage: .+ does not exist%.$")
              end, result.diagnostics)
            end

            return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
          end,
        },
      },

      yamlls = {
        settings = {
          yaml = {
            customTags = {
              "!reference sequence",
            },
          },
        },
      },
    },
  },
}
