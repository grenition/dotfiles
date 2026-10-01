local wezterm = require('wezterm')
local module = {}
function module.apply(config)
    config.color_scheme = 'Batman'

    config.initial_cols = 120
    config.initial_rows = 28

    config.font = wezterm.font 'JetBrains Mono'
    config.font_size = 18
end

return module;
