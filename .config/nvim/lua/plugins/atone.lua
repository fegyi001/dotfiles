return {
  "XXiaoA/atone.nvim",
  cmd = "Atone",
  event = "VeryLazy",
  config = function()
    require("atone").setup()
    vim.keymap.set("n", "<leader>uu", ":Atone toggle<CR>", { desc = "Toggle undo tree (Atone)" })
  end,
}
