-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Application bindings
-- o.bind("SUPER + RETURN", "Terminal", 'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"')
-- o.bind("SUPER + SHIFT + RETURN", "Browser", "omarchy-launch-browser")
-- o.bind("SUPER + SHIFT + F", "File manager", "uwsm-app -- nautilus --new-window")

-- Screenshot / Screen recording / Color picker
hl.unbind(", PRINT")
o.bind("SUPER + SHIFT + P", "Screenshot", "omarchy-cmd-screenshot")
hl.unbind("ALT, PRINT")
o.bind("SUPER + SHIFT + R", "Screenrecording", "omarchy-menu screenrecord")
hl.unbind("SUPER, PRINT")
o.bind("SUPER + SHIFT + C", "Color picker", "pkill hyprpicker || hyprpicker -a")

-- Launch apps
-- o.bind("SUPER + SPACE", "Launch apps", "fuzzel")
hl.unbind("SUPER + ALT, SPACE")
o.bind("SUPER + M", "Omarchy menu", "omarchy-menu")

-- TILING
hl.unbind("SUPER, W")
o.bind("SUPER + Q", "Close window", "killactive")
hl.unbind("CTRL + ALT, DELETE")
o.bind("SUPER + SHIFT + Q", "Close all windows", "omarchy-hyprland-window-close-all")

-- Nvim-style window focus movement
hl.unbind("SUPER, K")
hl.unbind("SUPER, SLASH")
hl.unbind("SUPER, H")
hl.unbind("SUPER, L")
hl.unbind("SUPER, J")
o.bind("SUPER + H", "Move window focus left", "movefocus l")
o.bind("SUPER + L", "Move window focus right", "movefocus r")
o.bind("SUPER + K", "Move window focus up", "movefocus u")
o.bind("SUPER + J", "Move window focus down", "movefocus d")
o.bind("SUPER + SLASH", "Show key bindings", "omarchy-menu-keybindings")

-- Switch apps
o.bind("SUPER + CTRL + ALT + J", "Firefox", 'omarchy-launch-or-focus firefox "uwsm-app -- firefox"')
o.bind("SUPER + CTRL + ALT + SHIFT + J", "Firefox", 'omarchy-launch-or-focus firefox "uwsm-app -- firefox"')
o.bind("SUPER + CTRL + ALT + I", "Chromium", 'omarchy-launch-or-focus chromium "uwsm-app -- chromium"')
o.bind("SUPER + CTRL + ALT + SHIFT + I", "Chromium", 'omarchy-launch-or-focus chromium "uwsm-app -- chromium"')
o.bind("SUPER + CTRL + ALT + K", "Foot", 'omarchy-launch-or-focus foot "uwsm-app -- alacritty"')
o.bind("SUPER + CTRL + ALT + SHIFT + K", "Foot", 'omarchy-launch-or-focus foot "uwsm-app -- alacritty"')
o.bind("SUPER + CTRL + ALT + M", "Microsoft Teams", 'omarchy-launch-or-focus teams "uwsm-app -- teams-for-linux"')
o.bind(
	"SUPER + CTRL + ALT + SHIFT + M",
	"Microsoft Teams",
	'omarchy-launch-or-focus teams "uwsm-app -- teams-for-linux"'
)

-- Screenshot variants
o.bind("SUPER + SHIFT + F10", "Screenshot Window", "omarchy-cmd-screenshot window")
o.bind("SUPER + SHIFT + F11", "Screenshot Region", "omarchy-cmd-screenshot")
o.bind("SUPER + SHIFT + F12", "Screenshot Display", "omarchy-cmd-screenshot output")

-- Volume
hl.unbind("SUPER, F10")
hl.unbind("SUPER, F11")
hl.unbind("SUPER, F12")
o.bind("SUPER + F10", "Mute", "$osdclient --output-volume mute-toggle")
o.bind("SUPER + F11", "Volume down", "$osdclient --output-volume lower")
o.bind("SUPER + F12", "Volume up", "$osdclient --output-volume raise")
