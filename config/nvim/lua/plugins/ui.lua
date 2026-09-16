local function lualine_opts()
  -- Project environment segment: "py:<venv>" or "go:<module>". Cached per
  -- buffer; BufWritePost in autocmds.lua drops vim.b.env_status so the
  -- segment follows project file changes.
  local function go_module()
    local root = vim.fs.root(0, { "go.mod" })
    if not root then
      return ""
    end

    local file = io.open(vim.fs.joinpath(root, "go.mod"), "r")
    if not file then
      return ""
    end

    local module
    for line in file:lines() do
      module = string.match(line, "^module%s+(%S+)")
      if module then
        break
      end
    end
    file:close()
    return module and vim.fs.basename(module) or ""
  end

  local function env_status()
    local segment = vim.b.env_status
    if segment == nil then
      segment = ""
      if vim.bo.filetype == "python" then
        segment = "py:" .. require("config.python").name()
      elseif vim.bo.filetype == "go" then
        segment = "go:" .. go_module()
      end
      vim.b.env_status = segment
    end
    return segment
  end

  local function lsp_clients()
    local names = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      names[#names + 1] = client.name
    end
    if #names == 0 then
      return ""
    end
    table.sort(names)
    return " " .. table.concat(names, ",")
  end

  -- Kubernetes manifest heuristic carried over from the hand-rolled
  -- statusline: badge likely-manifest YAML buffers.
  local function k8s_badge()
    if vim.bo.filetype ~= "yaml" then
      return nil
    end

    local path = vim.api.nvim_buf_get_name(0)
    local manifest = path:find("/k8s/", 1, true) ~= nil
      or path:find("/kubernetes/", 1, true) ~= nil
      or path:find("/manifests/", 1, true) ~= nil
      or path:match("%.k8s%.ya?ml$") ~= nil
      or path:match("%.kubernetes%.ya?ml$") ~= nil
    return manifest and "󱃾 K8S" or nil
  end

  return {
    options = {
      globalstatus = true,
      -- Palette-derived theme (lua/lualine/themes/vscode-custom.lua); the
      -- ColorScheme refresh in the config below re-resolves it per switch.
      theme = "vscode-custom",
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch" },
      lualine_c = {
        {
          "filename",
          path = 1,
          symbols = { modified = " [+]", readonly = " [RO]", unnamed = "[No Name]" },
        },
      },
      lualine_x = {
        { env_status, color = "DiagnosticInfo" },
        { lsp_clients, color = "DiagnosticInfo" },
        { k8s_badge, color = "DiagnosticInfo" },
        {
          "diagnostics",
          sources = { vim.diagnostic },
          symbols = { error = "", warn = "" },
          sections = { "error", "warn" },
        },
      },
      lualine_y = { "filetype" },
      lualine_z = { "location" },
    },
  }
end

return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      terminal_colors = true,
    },
  },
  {
    "akinsho/bufferline.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        close_command = function(buffer)
          require("config.buffers").close(buffer)
        end,
        middle_mouse_command = function(buffer)
          require("config.buffers").close(buffer)
        end,
        custom_filter = require("config.buffers").show_in_bufferline,
        color_icons = false,
        get_element_icon = function(element)
          local name = not element.directory and require("config.gitlab").is_ci_file(element.path) and ".gitlab-ci.yml"
            or vim.fs.basename(element.path)
          local icon = require("nvim-web-devicons").get_icon(name, element.extension, { default = true })

          -- Returning no icon highlight makes it inherit the exact tab
          -- background, including the transparent terminal theme.
          return icon or ""
        end,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diagnostics)
          if diagnostics.error and diagnostics.error > 0 then
            return string.format("  %d", diagnostics.error)
          end
          if diagnostics.warning and diagnostics.warning > 0 then
            return string.format("  %d", diagnostics.warning)
          end
          return ""
        end,
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        left_trunc_marker = "󰁍",
        right_trunc_marker = "󰁔",
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "thin",
        indicator = { style = "none" },
        tab_size = 12,
        max_name_length = 30,
        max_prefix_length = 18,
        sort_by = "insert_after_current",
        persist_buffer_sort = true,
        offsets = {
          {
            filetype = "neo-tree",
            text = "  EXPLORER",
            text_align = "left",
            separator = true,
          },
        },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      require("config.theme").apply_ui_highlights()
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 400,
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = lualine_opts,
    -- Custom theme strings are not re-resolved by upstream on ColorScheme, and
    -- re-running full setup would append duplicate reload autocmds (upstream
    -- never clears its group), so refresh the groups directly instead via the
    -- internal create_highlight_groups, verified against the locked revision.
    config = function(_, opts)
      require("lualine").setup(opts)
      vim.api.nvim_create_augroup("user_lualine_refresh", { clear = true })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = "user_lualine_refresh",
        callback = function()
          vim.schedule(function()
            require("lualine.highlight").create_highlight_groups(
              require("lualine.utils.loader").load_theme(opts.options.theme)
            )
          end)
        end,
      })
    end,
  },
}
