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

local function explorer_windows()
  local windows = picker_windows("rider_focus_editor")
  windows.list.keys.x = "rider_explorer_cut"
  windows.list.keys.y = { "rider_explorer_move_or_yank", mode = { "n", "x" } }
  windows.list.keys.p = "rider_explorer_move_or_paste"
  return windows
end

local function explorer_move_or(fallback)
  return function(picker)
    local actions = require("snacks.explorer.actions").actions
    if #picker:selected() > 0 then
      actions.explorer_move(picker)
    else
      actions[fallback](picker)
    end
  end
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
          rider_explorer_cut = function(picker)
            picker.list:select()
            local count = #picker:selected()
            Snacks.notify.info(count == 0 and "Move selection cleared" or ("Marked %d item(s) to move"):format(count))
          end,
          rider_explorer_move_or_yank = explorer_move_or("explorer_yank"),
          rider_explorer_move_or_paste = explorer_move_or("explorer_paste"),
        },
        win = picker_windows("rider_close_tool"),
        sources = {
          explorer = {
            win = explorer_windows(),
          },
        },
      },
    },
  },
}
