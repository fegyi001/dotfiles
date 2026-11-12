return {
  "christoomey/vim-tmux-navigator",
  event = "VeryLazy",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<C-h>", "<Cmd><C-U>TmuxNavigateLeft<CR>" },
    { "<C-j>", "<Cmd><C-U>TmuxNavigateDown<CR>" },
    { "<C-k>", "<Cmd><C-U>TmuxNavigateUp<CR>" },
    { "<C-l>", "<Cmd><C-U>TmuxNavigateRight<CR>" },
    { "<C-\\>", "<Cmd><C-U>TmuxNavigatePrevious<CR>" },
  },
  -- Only own navigation inside tmux, not Rex or Herdr.
  cond = function()
    return vim.env.TMUX ~= nil
      and vim.env.TMUX ~= ""
      and (vim.env.REX_SESSION == nil or vim.env.REX_SESSION == "")
      and vim.env.HERDR_PANE_ID == nil
  end,
}
