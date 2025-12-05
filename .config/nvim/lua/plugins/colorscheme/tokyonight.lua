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
    on_highlights = function(hl, colors)
      -- hl.CursorLine = { bg = "NONE" }
      -- hl.LspInlayHint = { bg = "NONE", fg = colors.dark3 }
      -- hl.AerialLine = { bg = "NONE", fg = colors.dark3 }
      -- hl.BufferLineSeparator = { fg = colors.bg, bg = colors.bg }
      -- hl.BufferLineSeparatorSelected = { fg = colors.bg, bg = colors.bg }
      -- hl.BufferLineSeparatorVisible = { fg = colors.bg, bg = colors.bg }
      -- hl.StatusLine = { bg = "NONE" }
    end,
  },
}
