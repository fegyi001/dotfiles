-- Import the snacks module
local snacks = require("snacks")
local material_icons = require("nvim-web-devicons")

local original_snacks_icon = snacks.util.icon

-- Override the snacks.util.icon function
snacks.util.icon = function(name, cat, opts)
  -- Get the icon and color from the material icons module
  local icon, color = material_icons.get_icon(name)

  -- In case of directory category, use the original snacks icon
  if cat == "directory" then
    icon, color = original_snacks_icon(name, cat, opts)
  end

  -- If no icon is found, fall back to the original snacks icon
  if not icon then
    icon, color = original_snacks_icon(name, cat, opts)
  end

  -- Return the icon and color
  return icon, color
end
