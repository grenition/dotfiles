-- https://wezterm.org/config/appearance.html

local wezterm = require('wezterm')
local module = {}
function module.get_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance()
    end
    return 'Dark'
end
function module.scheme_for_appearance(appearance)
    if appearance:find 'Dark' then
        return 'Vs Code Dark+ (Gogh)'
    else
        return 'Vs Code Light+ (Gogh)'
    end
end
function module.apply_to_config(config)
    --colors
    local appearance = module.get_appearance()
    local scheme = module.scheme_for_appearance(appearance)

    config.color_scheme = scheme
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

-- https://github.com/wez/wezterm/issues/6607
wezterm.on('window-config-reloaded', function(window)
    local scheme = module.scheme_for_appearance(window:get_appearance())
    if window:effective_config().color_scheme == scheme then
        return
    end
    local overrides = window:get_config_overrides() or {}
    overrides.color_scheme = scheme
    window:set_config_overrides(overrides)
end)

return module;
