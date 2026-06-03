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

-- Disable comma default behavior (reverse character search)
keymap.set("n", ",", "<nop>", { desc = "Disabled for beam.nvim", noremap = true, silent = true })
keymap.set("n", "<leader>l", "<nop>", { desc = "Disabled lazy default" })
keymap.set("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Open lazy" })

-- Helix-like movements
keymap.set({ "n", "v", "o" }, "gh", "^", { desc = "Go to first non-blank character", noremap = true, silent = true })
keymap.set({ "n", "v", "o" }, "gl", "$", { desc = "Go to end of line", noremap = true, silent = true })
keymap.set({ "n", "v", "o" }, "ge", "G", { desc = "Go to end of file", noremap = true, silent = true })

-- Other stuff
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

keymap.set("n", "<leader>ff", LazyVim.pick("files", { root = false, hidden = true }), { desc = "Find Files" })
keymap.set("n", "<leader><space>", LazyVim.pick("files", { root = false, hidden = true }), { desc = "Find Files" })
keymap.set("n", "<leader>fF", LazyVim.pick("files"), { desc = "Find Files (cwd)" })
keymap.set("n", "<leader>/", LazyVim.pick("grep", { root = false, hidden = true }), { desc = "Grep (Root Dir)" })
keymap.set("n", "<leader>e", function()
  local mf = require("mini.files")
  if not mf.close() then
    mf.open(vim.api.nvim_buf_get_name(0), true)
  end
end, {
  desc = "Toggle mini.files (Directory of Current File)",
})
keymap.set("n", "<leader>E", function()
  local mf = require("mini.files")
  if not mf.close() then
    mf.open(vim.uv.cwd(), true)
  end
end, {
  desc = "Toggle mini.files (cwd)",
})

-- Toggle Zoom
Snacks.toggle.zoom():map("<C-z>")

keymap.set("n", "<leader>tl", "<cmd>tablast<cr>", { desc = "Last Tab" })
keymap.set("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
keymap.set("n", "<leader>tf", "<cmd>tabfirst<cr>", { desc = "First Tab" })
keymap.set("n", "<leader>tt", "<cmd>tabnew<cr>", { desc = "New Tab" })
keymap.set("n", "<leader>tn", "<cmd>tabnext<cr>", { desc = "Next Tab" })
keymap.set("n", "<leader>td", "<cmd>tabclose<cr>", { desc = "Close Tab" })
keymap.set("n", "<leader>tp", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
