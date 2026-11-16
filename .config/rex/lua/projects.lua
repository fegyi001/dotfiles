rex.action({
	name = "open_project_picker",
	title = "Open Project Workspace",
	description = "Find a project folder and open or switch to its workspace",
	run = function(ctx)
		assert(ctx.client_id, "Open the project picker from a Rex app")
		assert(ctx.session_id, "Open the project picker from an existing workspace")
		local home = assert(os.getenv("HOME"), "HOME is not set")
		local window = assert(rex.session.new_window({
			window_label = "Projects",
			layout = rex.layout.block({
				flavor = "com.superlogical.terminal.shell",
				options = {
					cwd = home,
					command = { home .. "/.local/bin/rex-project-picker", "--client", ctx.client_id, "--picker-tab" },
					exit = { on_completion = true, quick_exit_threshold_ms = 0 },
				},
			}),
		}))
		-- Match tabs.lua: let Rex deliver the new window before asking the app to select it.
		local yielded, err = rex.exec({ "sleep", "0" }, { timeout = 1 })
		assert(yielded and yielded.ok, err or "Could not yield before selecting the project picker")
		rex.client.queue("session.select", { session_id = ctx.session_id, window_id = window.window_id })
	end,
})
