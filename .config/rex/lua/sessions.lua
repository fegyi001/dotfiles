local function command(ctx, operation)
  assert(ctx.client_id, "Switch sessions from a Rex app")
  assert(ctx.session_id, "Switch sessions from an existing session")
  local config = os.getenv("XDG_CONFIG_HOME")
  if not config or config == "" then
    config = assert(os.getenv("HOME"), "HOME is not set") .. "/.config"
  end
  return {
    "/bin/sh",
    config .. "/rex/scripts/session-picker.sh",
    operation,
    "--client",
    ctx.client_id,
    "--current",
    ctx.session_id,
  }
end

rex.action({
  name = "open_session_picker",
  title = "Switch Session (With History)",
  description = "Choose a session and remember this one for last-used switching",
  run = function(ctx)
    local argv = command(ctx, "pick")
    argv[#argv + 1] = "--picker-tab"
    local window_id
    if ctx.block_id then
      local description, err = rex.session.describe_block({ block_id = ctx.block_id })
      assert(description, err or "Could not locate the invoking pane")
      local block = description.block
      assert(block and block.placement == "placed", "Open the session picker from a placed pane")
      window_id = assert(block.window_id, "The invoking pane has no window")
    end
    local layer, err = rex.session.new_layer({
      window_id = window_id,
      bounds = { 0.15, 0.2, 0.7, 0.6 },
      focus = true,
      layout = rex.layout.block({
        flavor = "com.superlogical.terminal.shell",
        options = {
          command = argv,
          exit = { on_completion = true, quick_exit_threshold_ms = 0 },
        },
      }),
    })
    assert(layer, err or "Could not open the floating session picker")
  end,
})

rex.action({
  name = "last_used_session",
  title = "Last Used Session",
  description = "Switch back and forth between the last two sessions selected through the pickers",
  run = function(ctx)
    local result, err = rex.exec(command(ctx, "toggle"), { timeout = 60 })
    assert(result, err or "Could not run the session history helper")
    assert(result.ok, result.stderr ~= "" and result.stderr or "Could not switch to the last used session")
  end,
})
