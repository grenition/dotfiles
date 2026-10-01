-- https://wezterm.org/config/launch.html#the-launcher-menu

local module = {}
function module.apply(config)
    config.launch_menu = {
      {
        args = { 'top' },
      },
      {
        args = { 'vim', '~' },
      }
    }
end

return module
