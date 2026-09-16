local context_menu = require("config.neo_tree_context_menu")
local preview = require("config.neo_tree_preview")

local tree = {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function(_, opts)
    -- devicons registers the default icon highlights and its ColorScheme
    -- restorer only inside setup(); nothing else in this config calls it, so
    -- without this call every DevIcon* group stays undefined and tree icons
    -- render uncolored once a colorscheme switch wipes them.
    require("nvim-web-devicons").setup()
    -- Canonical devicons entries consumed by config.k8s for Kubernetes file
    -- detection. Registered once before setup so the first render resolves them.
    require("nvim-web-devicons").set_icon({
      ["kustomization.yaml"] = { icon = "󰠳", color = "#326ce5", name = "Kustomization" },
      ["k8s-manifest.yaml"] = { icon = "󰠳", color = "#326ce5", name = "Kubernetes" },
      ["secret.sops.yaml"] = { icon = "󰌋", color = "#e0af68", name = "SopsSecret" },
      ["helm.yaml"] = { icon = "󰠳", color = "#277a9f", name = "Helm" },
    })
    require("neo-tree").setup(opts)
  end,
  opts = {
    log_to_file = false,
    close_if_last_window = true,
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          -- JetBrains-style preview: entering the project tree starts a
          -- non-floating preview in the editor.
          vim.schedule(preview.show_selected)
          -- Keep GUI-style Shift+arrow selection out of the tree buffer:
          -- navigate like the tree's own h/j/k/l instead.
          local tree_nav = {
            ["<S-Up>"] = "k",
            ["<C-S-Up>"] = "k",
            ["<S-Down>"] = "j",
            ["<C-S-Down>"] = "j",
            ["<S-Left>"] = "h",
            ["<C-S-Left>"] = "h",
            ["<M-S-Left>"] = "h",
            ["<S-Home>"] = "h",
            ["<S-Right>"] = "l",
            ["<C-S-Right>"] = "l",
            ["<M-S-Right>"] = "l",
            ["<S-End>"] = "l",
          }
          for lhs, rhs in pairs(tree_nav) do
            vim.keymap.set("n", lhs, rhs, { buffer = 0, desc = "Navigate tree" })
          end
        end,
      },
      {
        event = "vim_cursor_moved",
        handler = preview.show_selected,
      },
      {
        event = "neo_tree_buffer_leave",
        handler = preview.leave,
      },
      {
        event = "file_opened",
        handler = preview.pin,
      },
    },
    default_component_configs = {
      -- VS Code-like 2-space guides with thin markers; colors come from the
      -- palette-derived NeoTreeIndentMarker group in config.theme.
      indent = {
        indent_size = 2,
        indent_marker = "│",
        last_indent_marker = "└╴",
        highlight = "NeoTreeIndentMarker",
      },
      icon = {
        provider = function(icon, node)
          if node.type ~= "file" and node.type ~= "terminal" then
            return
          end

          local name = node.type == "terminal" and "terminal" or node.name
          if node.type == "file" and require("config.gitlab").is_ci_file(node.path) then
            name = ".gitlab-ci.yml"
          end
          if node.type == "file" then
            local k8s = require("config.k8s").icon_name(node.path, node.name)
            if k8s then
              name = k8s
            end
          end

          local devicon, highlight = require("nvim-web-devicons").get_icon(name)
          icon.text = devicon or icon.text
          icon.highlight = highlight or icon.highlight
        end,
      },
      git_status = {
        symbols = {
          added = "+",
          deleted = "-",
          modified = "~",
          renamed = "→",
          untracked = "+",
          ignored = "○",
          unstaged = "~",
          staged = "✓",
          conflict = "!",
        },
      },
    },
    filesystem = {
      -- Keep the tree cursor under user control. Files opened via search,
      -- buffer tabs, LSP jumps, etc. must not reveal themselves implicitly.
      follow_current_file = { enabled = false },
      hijack_netrw_behavior = "open_default",
      use_libuv_file_watcher = vim.env.NVIM_CONFIG_CHECK ~= "1",
      commands = {
        context_menu = context_menu.open,
      },
    },
    window = {
      width = 26,
      auto_expand_width = true,
      mappings = {
        ["h"] = "close_node",
        ["l"] = "open",
        ["e"] = "toggle_auto_expand_width",
        ["j"] = function()
          vim.cmd.normal({ args = { "j" }, bang = true })
        end,
        ["k"] = function()
          vim.cmd.normal({ args = { "k" }, bang = true })
        end,
        ["x"] = "cut_to_clipboard",
        ["y"] = "copy_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["P"] = {
          "toggle_preview",
          config = preview.options,
        },
        ["m"] = {
          "add",
          config = {
            show_path = "none",
          },
        },
        ["M"] = "move",
        ["a"] = "context_menu",
      },
    },
  },
}

return {
  tree,
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = { "nvim-neo-tree/neo-tree.nvim" },
    config = function()
      require("lsp-file-operations").setup({ timeout_ms = 10000 })
    end,
  },
}
