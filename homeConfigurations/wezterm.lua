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

wezterm.on('update-status', function(window)
    -- Grab the utf8 character for the "powerline" left facing
    -- solid arrow.
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  
    -- Grab the current window's configuration, and from it the
    -- palette (this is the combination of your chosen colour scheme
    -- including any overrides).
    local color_scheme = window:effective_config().resolved_palette
    local bg = color_scheme.background
    local fg = color_scheme.foreground
  
    window:set_right_status(wezterm.format({
      -- First, we draw the arrow...
      { Background = { Color = 'none' } },
      { Foreground = { Color = bg } },
      { Text = SOLID_LEFT_ARROW },
      -- Then we draw our text
      { Background = { Color = bg } },
      { Foreground = { Color = fg } },
      { Text = ' ' .. wezterm.hostname() .. ' ' },
    }))
end)

return config
