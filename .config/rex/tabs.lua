rex.action({
  name = "new_indexed_tab",
  title = "New Numbered Tab",
  run = function(ctx)
    local view = assert(rex.session.view({}))
    local windows = view.windows or {}
    local block_id = ctx.block_id
    if not block_id then
      for _, window in ipairs(windows) do
        if window.window_id == view.active_window_id then
          block_id = window.focused_block_id
          break
        end
      end
    end

    local cwd
    if block_id then
      local process = assert(rex.block.call("com.superlogical.terminal", "process", { block_id = block_id }))
      cwd = process.foreground and process.foreground.cwd
      if not cwd then
        for _, ancestor in ipairs(process.ancestors or {}) do
          if ancestor.cwd then
            cwd = ancestor.cwd
            break
          end
        end
      end
      cwd = cwd or process.home
    end

    local window = assert(rex.session.new_window({
      window_label = tostring(#windows + 1),
      layout = rex.layout.block({
        flavor = "com.superlogical.terminal.shell",
        options = { cwd = cwd },
      }),
    }))
    rex.client.queue("session.select", { session_id = ctx.session_id, window_id = window.window_id })
  end,
})
