local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action
config.font_size = 14
config.window_decorations = 'RESIZE'
config.window_frame = {
    font_size = 13,
}
config.use_fancy_tab_bar = false
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.adjust_window_size_when_changing_font_size = false
config.front_end = "WebGpu"
config.max_fps = 120
config.mouse_wheel_scrolls_tabs = false
config.window_padding = {
    top = 2,
}
config.default_cwd = wezterm.home_dir

-- Custom keyboard shortcuts
config.keys = {
    {
        key = 'p',
        mods = 'ALT|CTRL',
        action = act.PaneSelect
    },
    {
        key = 'q',
        mods = 'ALT|CTRL',
        action = act.CloseCurrentPane { confirm = false }
    },
    {
        key = 'v',
        mods = 'ALT|CTRL',
        action = wezterm.action_callback(function(window, pane)
            local new_pane = pane:split { direction = 'Right' }
            new_pane:activate()
        end),
    },
    {
        key = 'h',
        mods = 'ALT|CTRL',
        action = wezterm.action_callback(function(window, pane)
            local new_pane = pane:split { direction = 'Bottom' }
            new_pane:activate()
        end),
    }
}

-- Turn off ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

return config
