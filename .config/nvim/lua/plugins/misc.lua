return {
  {
    "mawkler/modicator.nvim",
    event = "VeryLazy",
    dependencies = "mawkler/onedark.nvim", -- Add your colorscheme plugin here
    init = function()
      -- These are required for Modicator to work
      vim.o.cursorline = true
      vim.o.number = true
      vim.o.termguicolors = true
    end,
    opts = {
      -- Warn if any required option above is missing. May emit false positives
      -- if some other plugin modifies them, which in that case you can just
      -- ignore. Feel free to remove this line after you've gotten Modicator to
      -- work properly.
      show_warnings = true,
    },
  },
  {
    "chrisgrieser/nvim-chainsaw",
    event = "VeryLazy",
    opts = {}, -- required even if left empty
    init = function()
      local chainsaw = require("chainsaw")
      vim.keymap.set("n", "<leader>ag", function()
        chainsaw.variableLog()
      end, { desc = "Log variable" })
    end,
  },
  {
    "kawre/neotab.nvim",
    event = "InsertEnter",
    opts = {
      -- configuration goes here
    },
  },
}
