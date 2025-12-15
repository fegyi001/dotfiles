return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "moon",
    cache = true,
    dim_inactive = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = { italic = true },
      variables = {},
    },
    on_colors = function(colors)
      colors.border = "#565f89"
    end,
  },
}
