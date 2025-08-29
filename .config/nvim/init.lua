-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.icons")

-- CUSTOM MACROS

--Log variable in JS/TS
-- https://www.youtube.com/watch?v=Y3XWijJgdJs
local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
vim.api.nvim_create_augroup("JSLogMacro", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "JSLogMacro",
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.fn.setreg("l", "yoconsole.log('" .. esc .. "pa:" .. esc .. "la, " .. esc .. "pl")
  end,
})

vim.api.nvim_create_augroup("RustLogMacro", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "RustLogMacro",
  pattern = { "rust" },
  callback = function()
    vim.fn.setreg("l", "yoprintln!(\"" .. esc .. "pa: {:?}\", " .. esc .. "pa);" .. esc)
  end,
})
