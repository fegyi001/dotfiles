local wezterm = require("wezterm")
local config = wezterm.config_builder()
local colorscheme = wezterm.color.load_scheme(os.getenv("HOME") .. "/.config/wezterm/colors/tokyonight_moon.toml")
-- local backgroundImage = os.getenv("HOME") .. "/.config/wezterm/backgrounds/omarchy.png"
local backgroundColor = "#222437"
-- local backgroundColor = "#1C1D2B"

-- Preserve Cmd+Shift workspace navigation for Herdr without enabling the
-- Kitty keyboard protocol globally, which currently breaks plain Escape.
-- See https://github.com/sendhil/dotfiles-mac/commit/4f911efffd887b9e6b09d7797491e61944ab6c3f#diff-f022f8cd47d8636a83146650a2bbeb99130a8d3797431c8ebadfccf97585aa93
-- https://github.com/ogulcancelik/herdr/issues/1266
local function send_herdr_key(sequence, fallback_key, fallback_mods)
	return wezterm.action_callback(function(window, pane)
		local process = pane:get_foreground_process_name() or ""
		if process:match("/herdr$") then
			pane:send_text(sequence)
		else
			window:perform_action(wezterm.action.SendKey({ key = fallback_key, mods = fallback_mods }), pane)
		end
	end)
end

config = {
	color_schemes = {
		["tokyonight_moon"] = colorscheme,
	},
	window_close_confirmation = "NeverPrompt",
	color_scheme = "tokyonight_moon",
	colors = {
		background = backgroundColor,
		tab_bar = {
			background = backgroundColor,
			active_tab = {
				bg_color = "#1B1D2C",
				fg_color = "#ffc777",
			},
			inactive_tab = {
				bg_color = backgroundColor,
				fg_color = "#aaaaaa",
			},
			inactive_tab_hover = {
				bg_color = "#1B1D2C",
				fg_color = "#f8f8f2",
			},
		},
	},
	background = {
		{
			source = {
				Color = backgroundColor,
			},
			width = "100%",
			height = "100%",
		},
		-- {
		-- 	source = {
		-- 		File = backgroundImage,
		-- 	},
		-- 	width = "Cover",
		-- 	height = "Cover",
		-- 	horizontal_align = "Center",
		-- 	vertical_align = "Middle",
		-- 	opacity = 0.08,
		-- },
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
		left = 16,
		right = 1,
		top = 16,
		bottom = 0,
	},
	enable_scroll_bar = true,
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	window_decorations = "RESIZE",
	-- window_background_opacity = 0.93,
	-- window_background_opacity = 1,
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
		{
			key = "Escape",
			mods = "NONE",
			action = send_herdr_key("\x1b[27;1u", "Escape", "NONE"),
		},
		{
			key = "UpArrow",
			mods = "CMD|SHIFT",
			action = send_herdr_key("\x1b[1;10A", "UpArrow", "CMD|SHIFT"),
		},
		{
			key = "DownArrow",
			mods = "CMD|SHIFT",
			action = send_herdr_key("\x1b[1;10B", "DownArrow", "CMD|SHIFT"),
		},
		{
			key = "r",
			mods = "CMD|SHIFT",
			action = send_herdr_key("\x1b[114:82;10u", "r", "CMD|SHIFT"),
		},
	},
}

return config
