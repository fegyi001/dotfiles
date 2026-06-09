return {
  "folke/noice.nvim",
  opts = {
    lsp = {
      hover = {
        silent = true,
        opts = {
          border = {
            style = "rounded",
          },
        },
      },
      signature = {
        opts = {
          border = {
            style = "rounded",
          },
        },
      },
    },
    presets = {
      lsp_doc_border = true,
    },
  },
}
