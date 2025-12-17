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

if vim.fn.executable("lazygit") == 1 then
  keymap.set("n", "<leader>lg", function()
    Snacks.lazygit({ cwd = LazyVim.root.git() })
  end, { desc = "Lazygit (Root Dir)" })
  keymap.set("n", "<leader>lG", function()
    Snacks.lazygit()
  end, { desc = "Lazygit (cwd)" })
end

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

keymap.set("n", "<leader>tl", "<cmd>tablast<cr>", { desc = "Last Tab" })
keymap.set("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
keymap.set("n", "<leader>tf", "<cmd>tabfirst<cr>", { desc = "First Tab" })
keymap.set("n", "<leader>tt", "<cmd>tabnew<cr>", { desc = "New Tab" })
keymap.set("n", "<leader>tn", "<cmd>tabnext<cr>", { desc = "Next Tab" })
keymap.set("n", "<leader>td", "<cmd>tabclose<cr>", { desc = "Close Tab" })
keymap.set("n", "<leader>tp", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Custom function to delete buffers that are not visible in any window
local function delete_non_visible_buffers()
  -- Get all buffer numbers
  local all_buffers = vim.api.nvim_list_bufs()
  -- Get all visible buffers (buffers shown in windows)
  local visible_buffers = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    visible_buffers[buf] = true
  end
  -- Count deleted buffers for feedback
  local deleted_count = 0
  -- Delete buffers that are not visible and are valid/loaded
  for _, buf in ipairs(all_buffers) do
    if not visible_buffers[buf] and vim.api.nvim_buf_is_valid(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      local buf_modified = vim.bo[buf].modified
      -- Only delete if buffer is not modified and is not a special buffer
      if not buf_modified and buf_name ~= "" and not buf_name:match("^%w+://") then
        -- Use pcall to safely delete buffer
        local success, _ = pcall(vim.api.nvim_buf_delete, buf, { force = false })
        if success then
          deleted_count = deleted_count + 1
        end
      end
    end
  end
  -- Provide feedback
  if deleted_count > 0 then
    vim.notify("Deleted " .. deleted_count .. " non-visible buffer" .. (deleted_count == 1 and "" or "s"))
  else
    vim.notify("No non-visible buffers to delete")
  end
end

-- Override the default <leader>bo keybinding
keymap.set(
  "n",
  "<leader>bo",
  delete_non_visible_buffers,
  { desc = "Delete Non-Visible Buffers", noremap = true, silent = true }
)
