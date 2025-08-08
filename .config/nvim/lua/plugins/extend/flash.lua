return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    label = {
      rainbow = {
        enabled = false,
        -- shade = 4,
      },
    },
    modes = {
      char = {
        highlight = {
          backdrop = false,
        },
      },
    },
    highlight = {
      backdrop = false,
    },
  },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- { "<C-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
}
