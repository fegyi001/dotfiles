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
    local window = assert(rex.session.new_window({
      window_label = "Sessions",
      layout = rex.layout.block({
        flavor = "com.superlogical.terminal.shell",
        options = {
          command = argv,
          exit = { on_completion = true, quick_exit_threshold_ms = 0 },
        },
      }),
    }))
    -- Match the project picker: deliver the new window before asking the app to select it.
    local yielded, err = rex.exec({ "sleep", "0" }, { timeout = 1 })
    assert(yielded and yielded.ok, err or "Could not yield before selecting the session picker")
    rex.client.queue("session.select", { session_id = ctx.session_id, window_id = window.window_id })
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
