return {
  "lewis6991/gitsigns.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>hb",
      "<Cmd>Gitsigns blame_line<CR>",
      desc = "Blame Line",
    },
    {
      "<leader>hs",
      "<Cmd>Gitsigns stage_hunk<CR>",
      desc = "Stage Hunk",
    },
    {
      "<leader>hS",
      "<Cmd>Gitsigns stage_buffer<CR>",
      desc = "Stage Buffer",
    },
    {
      "<leader>hr",
      "<Cmd>Gitsigns reset_hunk<CR>",
      desc = "Reset Hunk",
    },
    {
      "<leader>hR",
      "<Cmd>Gitsigns reset_buffer<CR>",
      desc = "Reset Buffer",
    },
    {
      "<leader>hu",
      "<Cmd>Gitsigns undo_stage_hunk<CR>",
      desc = "Undo Stage Hunk",
    },
  },
}
