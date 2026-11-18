require("lua.tabs")
require("rex-navigator").setup({
	projects = {
		roots = {
			{ path = "~/code", depth = 2 },
			{ path = "~/dotfiles", depth = 1 },
			{ path = "~/data", depth = 1 },
		},
		exclude = { "node_modules" },
	},
})
require("lua.keys")
require("lua.navigation")
