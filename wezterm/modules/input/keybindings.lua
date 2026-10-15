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

        {
            key = 'LeftArrow',
            mods = 'CMD',
            action = wezterm.action.SendKey { key = 'Home' },
        },
        {
            key = 'RightArrow',
            mods = 'CMD',
            action = wezterm.action.SendKey { key = 'End' },
        },
        {
            key = 'UpArrow',
            mods = 'CMD',
            action = wezterm.action.SendKey { key = 'UpArrow', mods = 'CTRL' },
        },
        {
            key = 'DownArrow',
            mods = 'CMD',
            action = wezterm.action.SendKey { key = 'DownArrow', mods = 'CTRL' },
        },
        {
            key = 'Backspace',
            mods = 'CMD',
            action = wezterm.action.SendKey { key = 'u', mods = 'CTRL' },
        },
    }
end

return module
