return {
  "baggiponte/rex-navigator.nvim",
  main = "rex-navigator",
  lazy = false,
  cond = function()
    return vim.env.REX_SESSION ~= nil and vim.env.REX_SESSION ~= ""
  end,
  opts = {
    wrap = false,
  },
  config = function(_, opts)
    -- Apply after LazyVim installs its default Ctrl+h/j/k/l mappings.
    LazyVim.on_very_lazy(function()
      require("rex-navigator").setup(opts)
    end)
  end,
}
