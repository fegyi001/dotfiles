local wezterm = require("wezterm")

local config = wezterm.config_builder()

config = {
	window_close_confirmation = "NeverPrompt",
	color_scheme = "Monokai Pro (Gogh)",
	colors = {
		-- background = "#2d2a2c",
		background = "#303030",
	},
	font = wezterm.font_with_fallback({
		{
			family = "JetBrains Mono",
			weight = "Regular",
		},
		{
			family = "JetBrains Mono Nerd Font Mono",
		},
	}),
	font_size = 13.5,
	line_height = 1.2,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	enable_scroll_bar = false,
	enable_tab_bar = true,
	window_decorations = "RESIZE",
}

return config
