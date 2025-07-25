local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font_size = 17
config.font = wezterm.font("Fira Code")
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true

config.window_padding = {
    left = 0,
    right = 0,
    top = 10,
    bottom = 0,
}

return config
