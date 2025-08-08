return {
  {
    "Equilibris/nx.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    enabled = false,
    event = "VeryLazy",
    opts = {
      nx_cmd_root = "npx nx",
    },
    keys = {
      { "<leader>nxr", "<Cmd>Telescope nx actions<CR>", desc = "nx actions" },
      { "<leader>nxg", "<Cmd>Telescope nx generators<CR>", desc = "nx generators" },
    },
  },
}
