local json = require("lua.picker.json")
local text = require("lua.picker.text")
local M, Sessions = {}, {}
Sessions.__index = Sessions
local function nonempty(value)
  return type(value) == "string" and value ~= ""
end
local function quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

function M.new(R)
  return setmetatable({ R = R }, Sessions)
end

function Sessions:history_path()
  return (os.getenv("XDG_CONFIG_HOME") or assert(os.getenv("HOME")) .. "/.config") .. "/rex/state/session-history.json"
end

function Sessions:read_history()
  local ok, state = pcall(self.R.read_json, self.R, self:history_path(), json.object())
  local function invalid()
    error("Invalid session history: " .. self:history_path(), 0)
  end
  if not ok or not json.is_object(state) then
    invalid()
  end
  for _, clients in pairs(state) do
    if not json.is_object(clients) then
      invalid()
    end
    for _, entry in pairs(clients) do
      if not json.is_object(entry) or not nonempty(entry.current) or not nonempty(entry.previous) then
        invalid()
      end
      local count = 0
      for _ in pairs(entry) do
        count = count + 1
      end
      if count ~= 2 then
        invalid()
      end
    end
  end
  return state
end

function Sessions:last_used(clients, current, available)
  clients = clients or {}
  local entry = clients.shared
  if entry then
    return entry.current == current and entry.previous or entry.current
  end
  local candidates, target = {}, nil
  for _, legacy in pairs(clients) do
    local other
    if legacy.current == current then
      other = legacy.previous
    elseif legacy.previous == current then
      other = legacy.current
    end
    if other and other ~= current and available[other] then
      candidates[other] = true
    end
  end
  for candidate in pairs(candidates) do
    if target then
      error("Legacy session history is ambiguous; choose a session with the session or project picker", 0)
    end
    target = candidate
  end
  return target
end

function Sessions:picker_last_used(current, available)
  local ok, target = pcall(function()
    local state, populated = self:read_history(), false
    for _, clients in pairs(state) do
      if next(clients) then
        populated = true
        break
      end
    end
    if not populated then
      return
    end
    local result = self.R:run(
      { self.R:command_path("rex"), "--autostart=false", "api", "call", "server.status", "{}" },
      {
        timeout = 0.5,
        max_stdout = 256 * 1024,
      }
    )
    assert(result.ok)
    local status = json.decode(result.stdout)
    local scope = status.host_id or status.instance_id
    if not nonempty(scope) then
      return
    end
    local destination = self:last_used(state[scope], current, available)
    if destination ~= current and available[destination] then
      return destination
    end
  end)
  if ok then
    return target
  end
end

function Sessions:pick(context)
  local available, rows = {}, {}
  for _, session in ipairs(self.R:call("session.list", {}).sessions or {}) do
    if session.session_id ~= context.session_id then
      assert(nonempty(session.session_id) and session.session_id:match("^session:[%w:-]+$"), "Invalid session ID")
      rows[#rows + 1] = { id = session.session_id, label = text.session_label(session.label) }
      available[session.session_id] = true
    end
  end
  assert(#rows > 0, "No other sessions available")
  local target = self:picker_last_used(context.session_id, available)
  rows = self.R:sort_labels(rows)
  if target then
    for index, row in ipairs(rows) do
      if row.id == target then
        table.remove(rows, index)
        table.insert(rows, 1, row)
        break
      end
    end
  end
  local records, input = {}, {}
  for _, row in ipairs(rows) do
    local record = row.id .. "\t" .. row.label .. (row.id == target and " (last used)" or "")
    records[record], input[#input + 1] = row.id, record .. "\0"
  end
  local preview = "exec "
    .. quote(self.R:command_path("rex"))
    .. " --autostart=false do "
    .. quote(self.R.root .. "/scripts/session-preview.lua")
    .. " session={1}"
  local result = self.R:run({
    self.R:command_path("fzf"),
    "--read0",
    "--print0",
    "--no-multi",
    "--layout=reverse",
    "--delimiter=\t",
    "--with-nth=2..",
    "--tiebreak=index",
    "--preview",
    preview,
    "--preview-window=right,50%",
    "--bind=ctrl-u:preview-page-up,ctrl-d:preview-page-down",
    "--prompt=Session > ",
    "--border",
    "--header=Enter: switch session | Esc: cancel | Ctrl+U/D: scroll preview",
  }, { stdin = table.concat(input), timeout = false, env = self.R:picker_env() })
  if result.code == 1 or result.code == 130 or result.signal == "SIGINT" then
    return nil
  end
  assert(result.ok, "fzf failed with exit status " .. result.code)
  local selected = result.stdout:gsub("%z$", "")
  assert(records[selected], "fzf returned an unexpected selection")
  return records[selected]
end

function Sessions:switch(context, target)
  assert(nonempty(context.client_id) and nonempty(context.session_id), "--client and --current are required")
  return self.R:transaction(
    "session",
    { client = context.client_id, current = context.session_id, session = target },
    target ~= nil and 20 or 0
  )
end

function Sessions:commit_switch(request)
  local R = self.R
  local connected = false
  for _, app in ipairs(R:call("client.list", {}).clients or {}) do
    if
      app.client_id == request.client
      and app.info
      and app.info.kind == "app"
      and app.connection_state == "connected"
    then
      connected = true
      break
    end
  end
  assert(connected, "Choose a connected Rex app with --client CLIENT_ID (rex client ls)")
  local status = R:call("server.status", {})
  local scope = status.host_id or status.instance_id
  assert(nonempty(scope), "Could not identify the local Rex host")
  local state, available = self:read_history(), {}
  for _, session in ipairs(R:call("session.list", {}).sessions or {}) do
    available[session.session_id] = true
  end
  assert(available[request.current], "The source session no longer exists; reopen the picker")
  local target = request.session
  if target == nil then
    target = self:last_used(state[scope], request.current, available)
    assert(target, "No previous session yet; first switch with the session or project picker")
  end
  assert(available[target], "The previous or selected session was closed; choose another session with the picker")
  if target == request.current then
    return
  end
  R:select_client(request.client, target)
  state[scope] = state[scope] or json.object()
  state[scope].shared = json.object({ current = target, previous = request.current })
  local ok, err = pcall(R.save_json, R, self:history_path(), state)
  if not ok then
    error("Session switched, but history could not be saved: " .. tostring(err), 0)
  end
end

return M
