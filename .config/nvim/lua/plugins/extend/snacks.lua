local headers = {
  -- https://patorjk.com/software/taag/#p=display&f=Delta+Corps+Priest+1&t=fegyivim%0A&x=none&v=4&h=4&w=80&we=false
  fegyivim_omarchy = [[
   ▄████████    ▄████████    ▄██████▄  ▄██   ▄    ▄█   ▄█    █▄   ▄█    ▄▄▄▄███▄▄▄▄   
  ███    ███   ███    ███   ███    ███ ███   ██▄ ███  ███    ███ ███  ▄██▀▀▀███▀▀▀██▄ 
  ███    █▀    ███    █▀    ███    █▀  ███▄▄▄███ ███▌ ███    ███ ███▌ ███   ███   ███ 
 ▄███▄▄▄      ▄███▄▄▄      ▄███        ▀▀▀▀▀▀███ ███▌ ███    ███ ███▌ ███   ███   ███ 
▀▀███▀▀▀     ▀▀███▀▀▀     ▀▀███ ████▄  ▄██   ███ ███▌ ███    ███ ███▌ ███   ███   ███ 
  ███          ███    █▄    ███    ███ ███   ███ ███  ███    ███ ███  ███   ███   ███ 
  ███          ███    ███   ███    ███ ███   ███ ███  ███    ███ ███  ███   ███   ███ 
  ███          ██████████   ████████▀   ▀█████▀  █▀    ▀██████▀  █▀    ▀█   ███   █▀  
  ]],
  neovim_omarchy = [[
███▄▄▄▄      ▄████████  ▄██████▄   ▄█    █▄   ▄█    ▄▄▄▄███▄▄▄▄   
███▀▀▀██▄   ███    ███ ███    ███ ███    ███ ███  ▄██▀▀▀███▀▀▀██▄ 
███   ███   ███    █▀  ███    ███ ███    ███ ███▌ ███   ███   ███ 
███   ███  ▄███▄▄▄     ███    ███ ███    ███ ███▌ ███   ███   ███ 
███   ███ ▀▀███▀▀▀     ███    ███ ███    ███ ███▌ ███   ███   ███ 
███   ███   ███    █▄  ███    ███ ███    ███ ███  ███   ███   ███ 
███   ███   ███    ███ ███    ███ ███    ███ ███  ███   ███   ███ 
 ▀█   █▀    ██████████  ▀██████▀   ▀██████▀  █▀    ▀█   ███   █▀  
  ]],
  craft_it = [[
 ▄████████    ▄████████    ▄████████    ▄████████     ███           ▄█      ███     
███    ███   ███    ███   ███    ███   ███    ███ ▀█████████▄      ███  ▀█████████▄ 
███    █▀    ███    ███   ███    ███   ███    █▀     ▀███▀▀██      ███▌    ▀███▀▀██ 
███         ▄███▄▄▄▄██▀   ███    ███  ▄███▄▄▄         ███   ▀      ███▌     ███   ▀ 
███        ▀▀███▀▀▀▀▀   ▀███████████ ▀▀███▀▀▀         ███          ███▌     ███     
███    █▄  ▀███████████   ███    ███   ███            ███          ███      ███     
███    ███   ███    ███   ███    ███   ███            ███          ███      ███     
████████▀    ███    ███   ███    █▀    ███           ▄████▀        █▀      ▄████▀   
             ███    ███                                                             
  ]],
}

return {
  "folke/snacks.nvim",
  keys = {},
  opts = {
    dashboard = {
      preset = {
        header = headers.fegyivim_omarchy,
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          -- { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = "󰏖 ", key = "m", desc = "Mason", action = ":Mason" },
          {
            icon = " ",
            key = "g",
            desc = "Lazygit",
            action = function()
              Snacks.lazygit()
            end,
          },
          { icon = " ", key = "x", desc = "Extras", action = ":LazyExtras" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    local function set_dashboard_header_hl()
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#9ECE6A", bold = true })
    end
    set_dashboard_header_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_dashboard_header_hl,
    })
  end,
}
