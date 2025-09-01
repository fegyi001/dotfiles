return {
  "Piotr1215/beam.nvim",
  event = "VeryLazy",
  config = function()
    require("beam").setup({
      prefix = ",",
    })
  end,
}
