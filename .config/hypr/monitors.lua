-- Scale, resolution and arrangement are set from the monitor panel in the top
-- bar, as are refresh rate and rotation, and saved for each monitor in
-- ~/.local/state/omarchy/monitors/settings. This file is for what the panel
-- doesn't cover, and it loads after Omarchy's defaults. A choice made in the
-- panel still wins for that monitor, unless the panel's choices are switched
-- off below.
--
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Ignore the monitor panel's saved choices, so this file alone sets every
-- monitor, such as to keep the same setup in your dotfiles across machines.
-- The panel's changes then last only until Hyprland reloads. With the panel
-- off, match a monitor by its description rather than the port it's in:
-- hl.monitor({ output = "desc:Dell Inc. DELL U2723QE", mode = "preferred", position = "auto", scale = 1.5 })
-- omarchy_monitor_panel_settings = false

-- Scale every monitor without a choice of its own (Omarchy picks "auto").
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })

-- GTK and XWayland scale, a whole number (Omarchy sets 2 until a scale is
-- chosen in the panel, then follows the lowest monitor scale).
-- hl.env("GDK_SCALE", "1")

-- Keep a monitor off, such as the phantom output an Apple 6K XDR can show.
-- hl.monitor({ output = "DP-3", disabled = true })

-- Run a mode the panel doesn't offer: a resolution below 1080p or of another
-- shape, a fast rate at a resolution other than the current one, or a scale
-- outside its presets.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "auto", scale = 1.5 })

-- 10-bit color.
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, bitdepth = 10 })

-- Variable refresh rate (0 = off, 1 = always, 2 = fullscreen only).
-- hl.config({ misc = { vrr = 0 } })

-- Kept from your earlier monitors.lua, which is saved as monitors.lua.bak.1793600412.
local omarchy_monitor_scale = 2

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- BEGIN OMARCHY ARM QEMU VIRGL PROFILE
-- QEMU's Cocoa frontend publishes the live window's backing-pixel size and
-- host refresh rate through Virtio GPU EDID. Keep Quattro's preceding automatic
-- monitor rule authoritative so window resizing, Retina/non-Retina displays,
-- fullscreen, and 60/120 Hz hosts remain dynamic. Only hide the guest cursor:
-- Cocoa composes the host cursor outside the guest scanout for immediate motion.
local function omarchy_kernel_option_enabled(expected_option)
	if type(io) ~= "table" or type(io.open) ~= "function" then
		return false
	end

	local opened, cmdline_file = pcall(io.open, "/proc/cmdline", "r")
	if not opened or not cmdline_file then
		return false
	end

	local read_ok, cmdline = pcall(cmdline_file.read, cmdline_file, "*a")
	pcall(cmdline_file.close, cmdline_file)
	if not read_ok or type(cmdline) ~= "string" then
		return false
	end

	for option in cmdline:gmatch("%S+") do
		if option == expected_option then
			return true
		end
	end
	return false
end

if omarchy_kernel_option_enabled("omarchy.qemu_virgl=1") then
	hl.config({ cursor = { invisible = true } })
	o.exec_on_start("/usr/local/bin/omarchy-native-display-sync")
end
-- END OMARCHY ARM QEMU VIRGL PROFILE
