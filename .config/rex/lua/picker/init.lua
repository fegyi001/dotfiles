-- Importable entrypoint. Requiring it does not register actions or run commands.
local source = debug.getinfo(1, "S").source:gsub("^@", "")
local default_root = assert(source:match("^(.*)/lua/picker/[^/]+$"), "Could not locate Rex navigation root")
local M, configured = {}, false

function M.setup(options)
  assert(not configured, "Rex navigation setup must be called only once per config load")
  options = options or {}
  local root = options.root or default_root
  assert(root:sub(1, 1) == "/", "Rex navigation root must be absolute")
  local function command(kind, operation, ctx)
    assert(ctx.client_id, "Open the picker from a Rex app")
    assert(
      ctx.session_id,
      kind == "project" and "Open the project picker from an existing workspace"
        or "Switch sessions from an existing session"
    )
    local argv = { "/bin/sh", root .. "/scripts/picker.sh", kind }
    if operation then
      argv[#argv + 1] = operation
    end
    for _, arg in ipairs({ "--client", ctx.client_id, "--current", ctx.session_id }) do
      argv[#argv + 1] = arg
    end
    return argv
  end
  local function open(kind, ctx)
    local argv = command(kind, kind == "session" and "pick" or nil, ctx)
    argv[#argv + 1] = "--picker-tab"
    local window_id
    if ctx.block_id then
      local description, err = rex.session.describe_block({ session_id = ctx.session_id, block_id = ctx.block_id })
      assert(description, err or "Could not locate the invoking pane")
      local block = description.block
      assert(block and block.placement == "placed", "Open the picker from a placed pane")
      window_id = assert(block.window_id, "The invoking pane has no window")
    end
    local terminal = { command = argv, exit = { on_completion = true, quick_exit_threshold_ms = 0 } }
    if kind == "project" then
      terminal.cwd = assert(os.getenv("HOME"), "HOME is not set")
    end
    local layer, err = rex.session.new_layer({
      session_id = ctx.session_id,
      window_id = window_id,
      bounds = { 0.15, 0.2, 0.7, 0.6 },
      focus = true,
      layout = rex.layout.block({ flavor = "com.superlogical.terminal.shell", options = terminal }),
    })
    assert(layer, err or "Could not open the floating picker")
  end
  rex.action({
    name = "open_session_picker",
    title = "Switch Session (With History)",
    description = "Choose a session and remember this one for last-used switching",
    run = function(ctx)
      open("session", ctx)
    end,
  })
  rex.action({
    name = "open_project_picker",
    title = "Open Project Workspace",
    description = "Find a project folder and open or switch to its workspace",
    run = function(ctx)
      open("project", ctx)
    end,
  })
  rex.action({
    name = "last_used_session",
    title = "Last Used Session",
    description = "Switch back and forth between the last two sessions selected through the pickers",
    run = function(ctx)
      local result, err = rex.exec(command("session", "toggle", ctx), { timeout = 60 })
      assert(result, err or "Could not run the session history helper")
      assert(result.ok, result.stderr ~= "" and result.stderr or "Could not switch to the last used session")
    end,
  })
  configured = true
end

return M
