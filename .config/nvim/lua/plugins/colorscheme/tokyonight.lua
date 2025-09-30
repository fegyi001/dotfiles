return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "moon",
    cache = true,
    dim_inactive = true,
    transparent = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = { italic = true },
      variables = {},
      sidebars = "transparent",
      floats = "transparent",
    },
    on_colors = function(colors)
      colors.border = "#565f89"
    end,
    on_highlights = function(hl, _c)
      -- local Util = require("tokyonight.util")
      hl.CursorLine = { bg = "NONE" }
      -- hl.Normal = { fg = c.fg, bg = "NONE" }
      -- hl.NormalNC = { fg = c.fg, bg = Util.blend_bg(c.bg, 0.2) }
    end,
  },
}
