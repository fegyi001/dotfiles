vim.g.snacks_animate = false
vim.g.ai_cmp = false
vim.g.markdown_recommended_style = 0 -- Fix markdown indentation settings

local opt = vim.opt
opt.wrap = true
opt.syntax = "off"
opt.foldenable = false

vim.lsp.set_log_level("off")
vim.o.spell = false
