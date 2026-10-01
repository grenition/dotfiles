-- https://wezterm.org/config/appearance.html

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
    --colors
    config.color_scheme = scheme_for_appearance(get_appearance())
    config.inactive_pane_hsb = {
      saturation = 0.9,
      brightness = 0.8,
    }

    -- window
    config.initial_cols = 120
    config.initial_rows = 28
    config.window_padding = {
      left = 6,
      right = 6,
      top = 6,
      bottom = 6,
    }

    -- font
    config.font = wezterm.font('JetBrains Mono')
    config.font_size = 18

    -- tabs
    config.use_fancy_tab_bar = true
    config.enable_tab_bar = true
    config.hide_tab_bar_if_only_one_tab = true
    config.tab_bar_at_bottom = false
    config.window_frame = {

        font = wezterm.font('JetBrains Mono', {
            weight = 'Bold',
            stretch = 'Normal',
            style = 'Normal'
        }),
        font_size = 14.0,
    }
end

return module;
