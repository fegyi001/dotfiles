local wezterm = require("wezterm")

local config = wezterm.config_builder()

config = {
  window_close_confirmation = "NeverPrompt",
  -- color_scheme = "Monokai Pro (Gogh)",
  color_scheme = "Tokyo Night (Gogh)",
  colors = {
    background = "#1E2031",
    -- background = "#2d2a2c",
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
  font = wezterm.font_with_fallback({
    {
      family = "JetBrains Mono",
      weight = "Regular",
    },
    -- {
    --   family = "Liga SFMono Nerd Font"
    -- },
    {
      family = "JetBrainsMono Nerd Font",
    },
  }),
  font_size = 15,
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
  window_background_opacity = 1,
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
  },
}

return config
