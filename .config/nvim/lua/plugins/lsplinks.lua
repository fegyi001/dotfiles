return {
  "icholy/lsplinks.nvim",
  event = "VeryLazy",
  config = function()
    local lsplinks = require("lsplinks")
    lsplinks.setup()
    vim.keymap.set("n", "gx", lsplinks.gx)
  end,
}
