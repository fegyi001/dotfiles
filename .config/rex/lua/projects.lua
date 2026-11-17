rex.action({
	name = "open_project_picker",
	title = "Open Project Workspace",
	description = "Find a project folder and open or switch to its workspace",
	run = function(ctx)
		assert(ctx.client_id, "Open the project picker from a Rex app")
		assert(ctx.session_id, "Open the project picker from an existing workspace")
		local home = assert(os.getenv("HOME"), "HOME is not set")
		local window_id
		if ctx.block_id then
			local description, err = rex.session.describe_block({ block_id = ctx.block_id })
			assert(description, err or "Could not locate the invoking pane")
			local block = description.block
			assert(block and block.placement == "placed", "Open the project picker from a placed pane")
			window_id = assert(block.window_id, "The invoking pane has no window")
		end
		local layer, err = rex.session.new_layer({
			window_id = window_id,
			bounds = { 0.15, 0.2, 0.7, 0.6 },
			focus = true,
			layout = rex.layout.block({
				flavor = "com.superlogical.terminal.shell",
				options = {
					cwd = home,
					command = { home .. "/.local/bin/rex-project-picker", "--client", ctx.client_id, "--picker-tab" },
					exit = { on_completion = true, quick_exit_threshold_ms = 0 },
				},
			}),
		})
		assert(layer, err or "Could not open the floating project picker")
	end,
})
