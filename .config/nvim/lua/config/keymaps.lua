local keymap = vim.keymap

-- Move around with Ctrl-h, Ctrl-j, Ctrl-k, Ctrl-l in insert mode
keymap.set("i", "<C-h>", "<Left>")
keymap.set("i", "<C-l>", "<Right>")
keymap.set("i", "<C-j>", "<Down>")
keymap.set("i", "<C-k>", "<Up>")
keymap.set("i", "<C-e>", "<End>")

-- Redo with Shift-U
keymap.set("n", "<S-u>", "<C-r>", { desc = "Redo", noremap = true, silent = true })

-- Save with Ctrl-s
keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save", noremap = true, silent = true })

-- greatest keymap ever
-- https://www.youtube.com/watch?v=qZO9A5F6BZs
-- 6:26
keymap.set("x", "<leader>P", '"_dP', { desc = "Paste without replacing register", noremap = true, silent = true })

-- Other stuff
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

keymap.set("n", "<leader>ff", LazyVim.pick("files", { root = false, hidden = true }), { desc = "Find Files" })
keymap.set("n", "<leader><space>", LazyVim.pick("files", { root = false, hidden = true }), { desc = "Find Files" })
keymap.set("n", "<leader>fF", LazyVim.pick("files"), { desc = "Find Files (cwd)" })
keymap.set("n", "<leader>/", LazyVim.pick("grep", { root = false, hidden = true }), { desc = "Grep (Root Dir)" })
keymap.set("n", "<leader>e", LazyVim.pick("explorer", { root = false }), { desc = "Explorer Snacks" })
keymap.set("n", "<leader>fe", LazyVim.pick("explorer", { root = false }), { desc = "Explorer Snacks" })
keymap.set("n", "<leader>E", LazyVim.pick("explorer"), { desc = "Explorer Snacks (cwd)" })
keymap.set("n", "<leader>fE", LazyVim.pick("explorer"), { desc = "Explorer Snacks (cwd)" })
