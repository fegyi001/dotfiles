-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.icons")

-- registers
-- https://www.youtube.com/watch?v=Y3XWijJgdJs
local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
vim.fn.setreg("l", "yoconsole.log('" .. esc .. "pa:" .. esc .. "la, " .. esc .. "pl")
