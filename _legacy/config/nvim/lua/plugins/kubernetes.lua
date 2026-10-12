local tooling = require("config.tooling")

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters.kube_linter = {
      cmd = "kube-linter",
      args = { "lint", "--format", "json", "--with-color=false" },
      stdin = false,
      ignore_exitcode = true,
      parser = function(output, buffer)
        local ok, result = pcall(vim.json.decode, output)
        if not ok then
          return {}
        end

        local kind_line = 0
        for index, line in ipairs(vim.api.nvim_buf_get_lines(buffer, 0, -1, false)) do
          if line:match("^%s*kind:%s*%S") then
            kind_line = index - 1
            break
          end
        end

        local reports = type(result.Reports) == "table" and result.Reports or {}
        local diagnostics = {}
        for _, report in ipairs(reports) do
          local diagnostic = report.Diagnostic or {}
          table.insert(diagnostics, {
            lnum = kind_line,
            col = 0,
            severity = vim.diagnostic.severity.WARN,
            source = "kube-linter",
            code = report.Check,
            message = string.format("%s\n%s", diagnostic.Message or report.Check, report.Remediation or ""),
          })
        end

        return diagnostics
      end,
    }

    local function is_kubernetes_manifest(buffer)
      local has_api_version = false
      local has_kind = false

      for _, line in ipairs(vim.api.nvim_buf_get_lines(buffer, 0, -1, false)) do
        has_api_version = has_api_version or line:match("^%s*apiVersion:%s*%S") ~= nil
        has_kind = has_kind or line:match("^%s*kind:%s*%S") ~= nil
        if has_api_version and has_kind then
          return true
        end
      end

      return false
    end

    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("kubernetes_lint", { clear = true }),
      pattern = { "*.yaml", "*.yml" },
      callback = function(args)
        if
          vim.bo[args.buf].filetype == "yaml"
          and is_kubernetes_manifest(args.buf)
          and tooling.require("kube-linter")
        then
          lint.try_lint("kube_linter")
        end
      end,
    })
  end,
}
