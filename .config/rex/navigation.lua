local data = os.getenv("XDG_DATA_HOME")
if not data or data == "" then
  data = os.getenv("HOME") .. "/.local/share"
end

local plugin = data .. "/nvim/lazy/rex-navigator.nvim"
local ok, err = pcall(function()
  dofile(plugin .. "/rex/navigator.lua").setup({ wrap = false })
end)
if not ok then
  rex.log("warn", "rex-navigator not loaded: " .. tostring(err))
end
