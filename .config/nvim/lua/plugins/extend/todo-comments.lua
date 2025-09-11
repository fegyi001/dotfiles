return {
  "folke/todo-comments.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = { "TodoTrouble", "TodoTelescope" },
  event = "LazyFile",
  opts = {},
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
      { "<leader>xt", "<Cmd>Trouble todo toggle filter={buf=0,tag={TODO,FIX,FIXME,PERF,HACK}}<CR>", desc = "Todo (Trouble) current file" },
      { "<leader>xT", "<Cmd>Trouble todo toggle<CR>", desc = "Todo (Trouble)" },
      { "<leader>st", "<Cmd>TodoTelescope keywords=TODO,FIX,FIXME,PERF,HACK,WARNING<CR>", desc = "Todo (Telescope)" },
      { "<leader>sT", "<Cmd>TodoTelescope<CR>", desc = "Todo" },
    },
}
