local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)

-- Log variable in JS/TS
-- https://www.youtube.com/watch?v=Y3XWijJgdJs
vim.api.nvim_create_augroup("JSLogMacro", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "JSLogMacro",
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.fn.setreg("l", "yoconsole.log('" .. esc .. "pa:" .. esc .. "la, " .. esc .. "pl" .. esc)
  end,
})

-- Log variable in Rust
vim.api.nvim_create_augroup("RustLogMacro", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "RustLogMacro",
  pattern = { "rust" },
  callback = function()
    vim.fn.setreg("l", 'yoprintln!("' .. esc .. 'pa: {:?}", ' .. esc .. "pa);" .. esc)
  end,
})

