local colors = {
  red = "#F7768E",
  green = "#9ECE6A",
  orange = "#E0AF68",
  blue_dark = "#7AA2F7",
  purple = "#BB9AF7",
  blue_light = "#7DCFFF",
  grey = "#24283B",
}

-- local header_colors = { "#DAECC6", "#BBDD97", "#9ECE6A", "#678549", "#39482E" }
local header_colors = { colors.green, colors.green, colors.green, colors.green, colors.green }
local header_bands = { 1, 1, 2, 3, 3, 4, 5, 5 }

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
        function(self)
          local lines = vim.split(self.opts.preset.header:gsub("\n[ \t]*$", ""), "\n", { plain = true })
          local text = {}
          for row, line in ipairs(lines) do
            text[#text + 1] = {
              line .. (row < #lines and "\n" or ""),
              hl = "SnacksDashboardHeader" .. (header_bands[row] or 5),
            }
          end
          return { text = text, align = "center", padding = 1 }
        end,
        { text = { { headers.simple, hl = "SnacksDashboardSubHeader", align = "center" } }, padding = 0 },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
      preset = {
        header = headers.neovim_omarchy,
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
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = colors.green, bold = false })
      for band, color in ipairs(header_colors) do
        vim.api.nvim_set_hl(0, "SnacksDashboardHeader" .. band, { fg = color, bold = false })
      end
      vim.api.nvim_set_hl(0, "SnacksDashboardSubHeader", { fg = colors.blue_dark, bold = false })
    end
    set_dashboard_header_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_dashboard_header_hl,
    })
  end,
}
