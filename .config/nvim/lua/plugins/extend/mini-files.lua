return {
  "echasnovski/mini.files",
  event = "VeryLazy",
  dependencies = {
    "DaikyXendo/nvim-material-icon",
  },
  opts = function(_, opts)
    opts.windows = vim.tbl_deep_extend("force", opts.windows or {}, {
      preview = true,
      width_focus = 30,
      width_preview = 80,
    })
  end,
}
