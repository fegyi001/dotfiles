-- Read-only fzf preview supervisor. No state writes, focus changes, or terminal input.
local source = debug.getinfo(1, "S").source:gsub("^@", "")
local root = assert(source:match("^(.*)/scripts/[^/]+$"), "Could not locate Rex picker modules")
package.path = root .. "/?.lua;" .. root .. "/?/init.lua;" .. package.path
local R = require("lua.picker.runtime").new({ root = root })
require("lua.picker.preview").new(R):run(rex.args.session, os.getenv("FZF_PREVIEW_LINES"))
