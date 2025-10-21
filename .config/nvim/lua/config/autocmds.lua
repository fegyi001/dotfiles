-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.aei.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Angular component and service navigation
local function get_angular_file_base_and_type(file_path)
  local component_base = file_path:match("(.+)%.component%.html$")
    or file_path:match("(.+)%.component%.ts$")
    or file_path:match("(.+)%.component%.scss$")
    or file_path:match("(.+)%.component%.spec%.ts$")
  if component_base then
    return component_base, "component"
  end
  local service_base = file_path:match("(.+)%.service%.ts$") or file_path:match("(.+)%.service%.spec%.ts$")
  if service_base then
    return service_base, "service"
  end
  return nil, nil
end

local function open_angular_file(extension, file_type)
  return function()
    local current_file = vim.api.nvim_buf_get_name(0)
    local base_name, angular_type = get_angular_file_base_and_type(current_file)
    if base_name and angular_type then
      local target_file = base_name .. "." .. angular_type .. "." .. extension
      if vim.fn.filereadable(target_file) == 1 then
        vim.cmd("edit " .. target_file)
      else
        vim.notify(file_type .. " file not found: " .. vim.fn.fnamemodify(target_file, ":t"), vim.log.levels.WARN)
      end
    else
      vim.notify("Current file is not an Angular component or service file", vim.log.levels.WARN)
    end
  end
end

-- Create Angular file navigation commands
vim.api.nvim_create_user_command("AngularOpenHtml", open_angular_file("html", "Template"), {
  desc = "Open Angular html file",
})

vim.api.nvim_create_user_command("AngularOpenTs", open_angular_file("ts", "TypeScript"), {
  desc = "Open Angular typescript file",
})

vim.api.nvim_create_user_command("AngularOpenScss", open_angular_file("scss", "SCSS"), {
  desc = "Open Angular scss file",
})

vim.api.nvim_create_user_command("AngularOpenSpec", open_angular_file("spec.ts", "Spec"), {
  desc = "Open Angular spec file",
})

-- Angular file navigation keymaps
local wk = require("which-key")
wk.add({
  { "<leader>a", group = "Angular" },
})

vim.keymap.set("n", "<leader>aj", ":AngularOpenTs<CR>", {
  desc = "Open Angular typescript file",
  noremap = true,
  silent = true,
})

vim.keymap.set("n", "<leader>ak", ":AngularOpenHtml<CR>", {
  desc = "Open Angular html file",
  noremap = true,
  silent = true,
})

vim.keymap.set("n", "<leader>al", ":AngularOpenScss<CR>", {
  desc = "Open Angular scss file",
  noremap = true,
  silent = true,
})

vim.keymap.set("n", "<leader>ah", ":AngularOpenSpec<CR>", {
  desc = "Open Angular spec file",
  noremap = true,
  silent = true,
})
