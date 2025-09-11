return {
  "akinsho/git-conflict.nvim",
  event = "VeryLazy",
  opts = {
    default_mappings = {
      ours = "<leader>ho",
      theirs = "<leader>ht",
      none = "<leader>h0",
      both = "<leader>hb",
      next = "]x",
      prev = "[x",
    },
  },
  keys = {
    {
      "<leader>gx",
      "<Cmd>GitConflictListQf<CR>",
      desc = "List Conflicts",
    },
    {
      "<leader>gr",
      "<Cmd>GitConflictRefresh<CR>",
      desc = "Refresh Conflicts",
    },
  },
}
