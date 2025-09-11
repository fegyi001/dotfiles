-- Go to git root directory
local function entry()
	local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
	if handle then
		local git_root = handle:read("*a"):gsub("%s+", "")
		handle:close()
		
		if git_root and git_root ~= "" then
			ya.manager_emit("cd", { git_root })
		end
	end
end

return { entry = entry }