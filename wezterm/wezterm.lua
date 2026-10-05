-- https://wezterm.org/config/files.html

-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
require('modules.appearance').apply(config)
require('modules.launch_menu').apply(config)
require('modules.input.keybindings').apply(config)
require('modules.input.keytables').apply(config)
require('modules.input.mousebinding').apply(config)

-- Finally, return the configuration to wezterm:
return config
