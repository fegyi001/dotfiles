-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set(
  "n",
  "<leader>sx",
  require("telescope.builtin").resume,
  { noremap = true, silent = true, desc = "Resume" }
)

vim.keymap.set("n", "'", ":", { nowait = true, desc = "Command mode" })
-- vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("i", "jk", "<ESC>")
vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-l>", "<Right>")
vim.keymap.set("i", "<C-j>", "<Down>")
vim.keymap.set("i", "<C-k>", "<Up>")
vim.keymap.set("i", "<C-e>", "<End>")

-- M.general = {
--   n = {
--     ["[e"] = { ":<C-u>execute 'move -1-'. v:count1<cr>" },
--     ["]e"] = { ":<C-u>execute 'move +'. v:count1<cr>" },
--     ["[<space>"] = { ":<c-u>put! =repeat(nr2char(10), v:count1)<cr>" },
--     ["]<space>"] = { ":<c-u>put =repeat(nr2char(10), v:count1)<cr>" },
--   },
-- }
