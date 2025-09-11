return {
  "allaman/emoji.nvim",
  version = "1.0.0", -- optionally pin to a tag
  ft = "markdown", -- adjust to your needs
  enabled = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "ibhagwan/fzf-lua",
  },
  event = "VeryLazy",
  config = function(_, opts)
    require("emoji").setup(opts)
    local ts = require("telescope").load_extension("emoji")
    vim.keymap.set("n", "<leader>fe", ts.emoji, { desc = "Search Emoji" })
  end,
}
