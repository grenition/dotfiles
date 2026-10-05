-- https://wezterm.org/config/keys.html

local wezterm = require('wezterm')
local module = {}

function module.apply_to_config(config)
   config.keys = {
      {
        key = 'y',
        mods = 'CMD',
        action = wezterm.action.SpawnCommandInNewWindow {
          args = { 'top' },
        },
      },
      {
        key = 'l',
        mods = 'CMD',
        action = wezterm.action.ShowLauncher
      },
      {
        key = ',',
        mods = 'CMD',
        action = wezterm.action.SpawnCommandInNewWindow {
          label = 'Modify dotfiles',
          args = { 'nvim', '.' },
          cwd = "$DOTFILES_DIR",
          set_environment_variables = {
              PATH = '$PATH'
          }
        },
      },
    }
end

return module
