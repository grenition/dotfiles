local function picker_keys(modes, escape_action)
  return {
    ["<Esc>"] = { escape_action, mode = modes },
    ["<C-Esc>"] = { "rider_close_tool", mode = modes },
    ["<C-S-Esc>"] = { "rider_close_all_tools", mode = modes },
  }
end

local function picker_windows(escape_action)
  return {
    input = { keys = picker_keys({ "i", "n" }, escape_action) },
    list = { keys = picker_keys({ "n", "x" }, escape_action) },
    preview = { keys = picker_keys({ "n", "x" }, escape_action) },
  }
end

return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- Neovim's built-in default scheme uses the terminal's ANSI palette and
      -- has the same understated look as stock netrw.
      colorscheme = "default",
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
      picker = {
        auto_close = false,
        actions = {
          rider_focus_editor = function()
            vim.schedule(function()
              pcall(vim.cmd.stopinsert)
              require("config.tool_windows").focus_editor()
            end)
          end,
          rider_close_tool = function(picker)
            picker:close()
            vim.schedule(function()
              require("config.tool_windows").focus_editor()
            end)
          end,
          rider_close_all_tools = function(picker)
            picker:close()
            vim.schedule(function()
              require("config.tool_windows").close_all_tool_windows()
            end)
          end,
        },
        win = picker_windows("rider_close_tool"),
        sources = {
          explorer = {
            win = picker_windows("rider_focus_editor"),
          },
        },
      },
    },
  },
}
