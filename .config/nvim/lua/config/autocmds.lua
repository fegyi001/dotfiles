-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.aei.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Angular component navigation
local function get_angular_component_base(file_path)
  return file_path:match("(.+)%.component%.html$")
    or file_path:match("(.+)%.component%.ts$")
    or file_path:match("(.+)%.component%.scss$")
    or file_path:match("(.+)%.component%.spec%.ts$")
end

local function open_angular_component_file(extension, file_type)
  return function()
    local current_file = vim.api.nvim_buf_get_name(0)
    local base_name = get_angular_component_base(current_file)
    if base_name then
      local target_file = base_name .. ".component." .. extension
      if vim.fn.filereadable(target_file) == 1 then
        vim.cmd("edit " .. target_file)
      else
        vim.notify(file_type .. " file not found: " .. vim.fn.fnamemodify(target_file, ":t"), vim.log.levels.WARN)
      end
    else
      vim.notify("Current file is not an Angular component file", vim.log.levels.WARN)
    end
  end
end

-- Create Angular component navigation commands
vim.api.nvim_create_user_command("AngularOpenComponentHtml", open_angular_component_file("html", "Template"), {
  desc = "Open corresponding Angular component template (HTML) file",
})

vim.api.nvim_create_user_command("AngularOpenComponentTs", open_angular_component_file("ts", "TypeScript"), {
  desc = "Open corresponding Angular component TypeScript file",
})

vim.api.nvim_create_user_command("AngularOpenComponentScss", open_angular_component_file("scss", "SCSS"), {
  desc = "Open corresponding Angular component SCSS file",
})

vim.api.nvim_create_user_command("AngularOpenComponentSpec", open_angular_component_file("spec.ts", "Spec"), {
  desc = "Open corresponding Angular component spec file",
})

-- Angular component navigation keymaps
local wk = require("which-key")
wk.add({
  { "<leader>a", group = "Angular" },
})

vim.keymap.set("n", "<leader>aj", ":AngularOpenComponentTs<CR>", {
  desc = "Open Angular TypeScript file",
  noremap = true,
  silent = true,
})

vim.keymap.set("n", "<leader>ak", ":AngularOpenComponentHtml<CR>", {
  desc = "Open Angular template file",
  noremap = true,
  silent = true,
})

vim.keymap.set("n", "<leader>al", ":AngularOpenComponentScss<CR>", {
  desc = "Open Angular SCSS file",
  noremap = true,
  silent = true,
})

vim.keymap.set("n", "<leader>ah", ":AngularOpenComponentSpec<CR>", {
  desc = "Open Angular spec file",
  noremap = true,
  silent = true,
})
