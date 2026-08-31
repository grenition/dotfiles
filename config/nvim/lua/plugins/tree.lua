local preview_config = {
  use_float = false,
  use_snacks_image = false,
  use_image_nvim = false,
}

local preview_buffer

local function discard_previous_preview(next_buffer)
  local buffer = preview_buffer
  if not buffer or buffer == next_buffer then
    return
  end

  preview_buffer = nil
  if not vim.api.nvim_buf_is_valid(buffer) then
    return
  end
  if vim.bo[buffer].modified or vim.fn.bufwinid(buffer) ~= -1 then
    vim.b[buffer].jetbrains_preview = nil
    return
  end

  vim.b[buffer].jetbrains_preview = nil
  pcall(vim.api.nvim_buf_delete, buffer, {})
end

local function pin_preview(path)
  local buffer = preview_buffer
  if not buffer or not vim.api.nvim_buf_is_valid(buffer) then
    preview_buffer = nil
    return
  end

  if vim.fs.normalize(vim.api.nvim_buf_get_name(buffer)) == vim.fs.normalize(path) then
    vim.b[buffer].jetbrains_preview = nil
    preview_buffer = nil
  end
end

local function preview_selected_file()
  if vim.bo.filetype ~= "neo-tree" then
    return
  end

  local state = require("neo-tree.sources.manager").get_state_for_window()
  if not state or not state.tree then
    return
  end

  local preview = require("neo-tree.sources.common.preview")
  local node = state.tree:get_node()
  if not node or node.type ~= "file" then
    preview.hide()
    return
  end

  local existing_buffer = vim.fn.bufnr(node.path)
  local owns_buffer = existing_buffer < 0
    or vim.fn.buflisted(existing_buffer) == 0
    or vim.b[existing_buffer].jetbrains_preview == true

  state.config = preview_config
  preview.show(state)

  local buffer = vim.fn.bufnr(node.path)
  if buffer < 0 then
    return
  end

  discard_previous_preview(buffer)
  vim.bo[buffer].buflisted = true
  vim.b[buffer].jetbrains_preview = owns_buffer or nil
  preview_buffer = owns_buffer and buffer or nil
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    close_if_last_window = true,
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          -- JetBrains-style preview: entering the project tree starts a
          -- non-floating preview in the editor.
          vim.schedule(preview_selected_file)
        end,
      },
      {
        event = "vim_cursor_moved",
        handler = preview_selected_file,
      },
      {
        event = "neo_tree_buffer_leave",
        handler = function()
          require("neo-tree.sources.common.preview").hide()
        end,
      },
      {
        event = "file_opened",
        handler = pin_preview,
      },
    },
    default_component_configs = {
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
      use_libuv_file_watcher = true,
    },
    window = {
      width = 26,
      mappings = {
        ["h"] = "close_node",
        ["l"] = "open",
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
          config = preview_config,
        },
      },
    },
  },
}
