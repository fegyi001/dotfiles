return {
  "github/copilot.vim",
  event = "VeryLazy",
  keys = function()
    local keys = {
      {
        "<leader>ct",
        function()
          if vim.b.copilot_enabled == false then
            vim.b.copilot_enabled = true
            print("Copilot enabled")
          else
            vim.b.copilot_enabled = false
            print("Copilot disabled")
          end
        end,
        desc = "Copilot Toggle",
      },
    }
    return keys
  end,
}
