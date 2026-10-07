local colors = {
  red = "#F7768E",
  green = "#9ECE6A",
  orange = "#E0AF68",
  blue_dark = "#7AA2F7",
  purple = "#BB9AF7",
  blue_light = "#7DCFFF",
  grey = "#24283B",
}

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
  -- https://patorjk.com/software/taag/#p=display&f=DiamFont&t=enjoy+the+ride%0A&x=none&v=4&h=4&w=80&we=false
  enjoy_the_ride = [[
▗▞▀▚▖▄▄▄▄     ▗▖ ▄▄▄  ▄   ▄        ■  ▐▌   ▗▞▀▚▖     ▄▄▄ ▄    ▐▌▗▞▀▚▖
▐▛▀▀▘█   █    ▗▖█   █ █   █     ▗▄▟▙▄▖▐▌   ▐▛▀▀▘    █    ▄    ▐▌▐▛▀▀▘
▝▚▄▄▖█   █ ▄  ▐▌▀▄▄▄▀  ▀▀▀█       ▐▌  ▐▛▀▚▖▝▚▄▄▖    █    █ ▗▞▀▜▌▝▚▄▄▖
           ▀▄▄▞▘      ▄   █       ▐▌  ▐▌ ▐▌              █ ▝▚▄▟▌     
                       ▀▀▀        ▐▌                                 
  ]],
  simple = [[
  enjoy • the • ride
  ]],
}

return {
  "folke/snacks.nvim",
  keys = {},
  opts = {
    dashboard = {
      sections = {
        { section = "header", padding = 1 },
        { text = { { headers.simple, hl = "SnacksDashboardSubHeader", align = "center" } }, padding = 2 },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
      preset = {
        header = headers.fegyivim_omarchy,
        keys = {
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = "󰇥 ", key = "y", desc = "Yazi", action = ":Yazi" },
          {
            icon = " ",
            key = "g",
            desc = "Lazygit",
            action = function()
              Snacks.lazygit()
            end,
          },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = "󰏖 ", key = "m", desc = "Mason", action = ":Mason" },
          { icon = " ", key = "x", desc = "Extras", action = ":LazyExtras" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    local function set_dashboard_header_hl()
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = colors.green, bold = true })
      vim.api.nvim_set_hl(0, "SnacksDashboardSubHeader", { fg = colors.blue_dark, bold = false })
    end
    set_dashboard_header_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_dashboard_header_hl,
    })
  end,
}
