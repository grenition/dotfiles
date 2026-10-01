local wezterm = require('wezterm')
local module = {}

local function get_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance()
    end
    return 'Dark'
end
local function scheme_for_appearance(appearance)
    if appearance:find 'Dark' then
        return 'Vs Code Dark+ (Gogh)'
    else
        return 'Vs Code Light+ (Gogh)'
    end
end
function module.apply(config)
    config.color_scheme = scheme_for_appearance(get_appearance())

    config.initial_cols = 120
    config.initial_rows = 28

    config.font = wezterm.font 'JetBrains Mono'
    config.font_size = 18
end

return module;
