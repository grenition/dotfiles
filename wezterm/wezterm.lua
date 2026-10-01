-- https://wezterm.org/config/files.html

-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.
require('modules.appearance').apply(config)
require('modules.keymaps').apply(config)
require('modules.launch_menu').apply(config)

-- Finally, return the configuration to wezterm:
return config
