-- https://wezterm.org/config/files.html

-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
require('modules.appearance').apply_to_config(config)
require('modules.launch_menu').apply_to_config(config)

require('modules.input.keybindings').apply_to_config(config)
require('modules.input.keytables').apply_to_config(config)
require('modules.input.mousebinding').apply_to_config(config)

-- Finally, return the configuration to wezterm:
return config
