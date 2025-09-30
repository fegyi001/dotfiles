local wezterm = require("wezterm")

local config = wezterm.config_builder()
local colorscheme = wezterm.color.load_scheme(os.getenv("HOME") .. "/.config/wezterm/colors/tokyonight_moon.toml")

config = {
	color_schemes = {
		["tokyonight_moon"] = colorscheme,
	},
	window_close_confirmation = "NeverPrompt",
	color_scheme = "tokyonight_moon",
	colors = {
		background = "#222437",
		tab_bar = {
			background = "#3A3A3A",
			active_tab = {
				bg_color = "#3A3A3A",
				fg_color = "#FBDE65",
			},
			inactive_tab = {
				bg_color = "#3A3A3A",
				fg_color = "#aaaaaa",
			},
			inactive_tab_hover = {
				bg_color = "#3A3A3A",
				fg_color = "#f8f8f2",
			},
		},
	},
	use_fancy_tab_bar = true,
	tab_max_width = 20,
	bold_brightens_ansi_colors = true,
	font = wezterm.font_with_fallback({
		{
			family = "JetBrains Mono",
			weight = "Medium",
		},
		{
			family = "JetBrainsMono Nerd Font",
		},
	}),
	font_rules = {
		{
			intensity = "Bold",
			italic = true,
			font = wezterm.font({ family = "Maple Mono", weight = "Bold", style = "Italic" }),
		},
		{
			intensity = "Half",
			italic = true,
			font = wezterm.font({ family = "Maple Mono", weight = "DemiBold", style = "Italic" }),
		},
		{
			intensity = "Normal",
			italic = true,
			font = wezterm.font({ family = "Maple Mono", style = "Italic" }),
		},
	},
	harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
	font_size = 14,
	line_height = 1.3,
	window_padding = {
		left = 5,
		right = 5,
		top = 0,
		bottom = 0,
	},
	enable_scroll_bar = true,
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	window_decorations = "RESIZE",
	window_background_opacity = 0.9,
	-- macos_window_background_blur = 10,
	native_macos_fullscreen_mode = false,
	keys = {
		{
			key = "J",
			mods = "CTRL|SHIFT",
			action = wezterm.action.QuickSelect,
		},
		{
			key = "K",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivateCopyMode,
		},
		{ key = "-", mods = "CMD", action = wezterm.action.DecreaseFontSize },
		{ key = "+", mods = "CMD", action = wezterm.action.IncreaseFontSize },
		{ key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
	},
}

return config
