return {
  "folke/snacks.nvim",
  keys = {},
  opts = {
    dashboard = {
      preset = {
        header = [[
███████╗███████╗ ██████╗██╗   ██╗██╗██╗   ██╗██╗███╗   ███╗
██╔════╝██╔════╝██╔════╝╚██╗ ██╔╝██║██║   ██║██║████╗ ████║
█████╗  █████╗  ██║  ███╗╚████╔╝ ██║██║   ██║██║██╔████╔██║
██╔══╝  ██╔══╝  ██║   ██║ ╚██╔╝  ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║     ███████╗╚██████╔╝  ██║   ██║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝     ╚══════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
        ]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
  },
}
