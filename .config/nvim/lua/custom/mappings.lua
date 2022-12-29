local M = {}

M.general = {
  n = {
    ["'"] = { ":", "command mode", opts = { nowait = true } },
    ["<leader>gg"] = { ":LazyGit<CR>" },
    ["<C-d>"] = { "<C-d>zz" },
    ["<C-u>"] = { "<C-u>zz" },
    ["n"] = { "nzzzv" },
    ["N"] = { "Nzzzv" },
    ["[e"] = { ":<C-u>execute 'move -1-'. v:count1<cr>" },
    ["]e"] = { ":<C-u>execute 'move +'. v:count1<cr>" },
    ["[<space>"] = { ":<c-u>put! =repeat(nr2char(10), v:count1)<cr>" },
    ["]<space>"] = { ":<c-u>put =repeat(nr2char(10), v:count1)<cr>" },
  },
}

-- more keybinds!

return M
