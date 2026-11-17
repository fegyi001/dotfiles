local json = require("lua.picker.json")
local text = require("lua.picker.text")
local M, Projects = {}, {}
Projects.__index = Projects
local function nonempty(value)
  return type(value) == "string" and value ~= ""
end
function M.new(R, S)
  return setmetatable({ R = R, S = S }, Projects)
end

function Projects:pick(config_path)
  local R = self.R
  config_path = config_path
    or (os.getenv("XDG_CONFIG_HOME") or assert(os.getenv("HOME")) .. "/.config") .. "/rex/projects.json"
  local config = R:read_json(config_path, nil)
  assert(
    json.is_object(config) and json.is_array(config.roots) and #config.roots > 0,
    "projects.json must contain a nonempty roots list"
  )
  local exclude = config.exclude
  if exclude == nil then
    exclude = json.array({ "node_modules", "vendor", "__pycache__" })
  end
  assert(json.is_array(exclude), "exclude must be a list of directory names")
  for _, name in ipairs(exclude) do
    assert(nonempty(name), "exclude must be a list of directory names")
  end
  local roots = {}
  for _, root in ipairs(config.roots) do
    assert(json.is_object(root) and nonempty(root.path), "each root needs a nonempty path")
    assert(
      type(root.depth) == "number" and root.depth >= 1 and root.depth % 1 == 0,
      "each root needs a positive integer depth"
    )
    assert(
      root.path:sub(1, 1) == "/" or root.path == "~" or root.path:sub(1, 2) == "~/",
      "root paths must be absolute or start with ~/"
    )
    local ok, path = pcall(R.canonical_path, R, root.path)
    if ok then
      roots[#roots + 1] = { path = path, depth = root.depth }
    else
      io.stderr:write("Warning: skipping unusable root " .. root.path .. ": " .. tostring(path) .. "\n")
    end
  end
  local paths = R:discover(roots, exclude)
  assert(#paths > 0, "No project directories found. Check your Rex projects.json roots.")
  local allowed = {}
  for _, path in ipairs(paths) do
    allowed[path] = true
  end
  local result = R:run({
    R:command_path("fzf"),
    "--read0",
    "--print0",
    "--no-multi",
    "--layout=reverse",
    "--prompt=Project > ",
    "--border",
    "--header=Enter: open workspace | Esc: cancel",
  }, { timeout = false, stdin = table.concat(paths, "\0") .. "\0", env = R:picker_env() })
  if result.code == 1 or result.code == 130 or result.signal == "SIGINT" then
    return nil
  end
  assert(result.ok, "fzf failed with exit status " .. result.code)
  if result.stdout == "" then
    return nil
  end
  local selected = result.stdout:gsub("%z$", "")
  assert(allowed[selected], "fzf returned an unexpected selection")
  return selected
end

function Projects:registry_path()
  return (os.getenv("XDG_STATE_HOME") or assert(os.getenv("HOME")) .. "/.local/state") .. "/rex/project-sessions.json"
end

function Projects:read_registry()
  local ok, state = pcall(self.R.read_json, self.R, self:registry_path(), json.object())
  local function invalid()
    error("Invalid project-session registry: " .. self:registry_path(), 0)
  end
  if not ok or not json.is_object(state) then
    invalid()
  end
  for _, mapping in pairs(state) do
    if not json.is_object(mapping) then
      invalid()
    end
    for _, session_id in pairs(mapping) do
      if not nonempty(session_id) then
        invalid()
      end
    end
  end
  return state
end

function Projects:resolve_client(requested)
  requested = requested or os.getenv("REX_CLIENT")
  if requested == "" then
    requested = nil
  end
  local matches = {}
  for _, app in ipairs(self.R:call("client.list", {}).clients or {}) do
    if
      app.info
      and app.info.kind == "app"
      and app.connection_state == "connected"
      and (not requested or requested == app.client_id)
    then
      matches[#matches + 1] = app.client_id
    end
  end
  assert(#matches == 1, "Choose exactly one connected Rex app with --client CLIENT_ID (rex client ls)")
  return matches[1]
end

function Projects:open(context, directory, picker_block)
  assert(nonempty(context.session_id), "Open the project picker from an existing Rex session (REX_SESSION is not set)")
  directory = self.R:canonical_path(directory)
  assert(self.R:is_directory(directory), "Project directory no longer exists: " .. directory)
  local client = self:resolve_client(context.client_id)
  local target = self.R:transaction("project", {
    directory = directory,
    client = client,
    current = context.session_id,
    picker_block = picker_block,
  }, 20)
  assert(nonempty(target), "Rex did not return a session ID; inspect sessions before retrying creation")
  return self.S:switch({ client_id = client, session_id = context.session_id }, target)
end

function Projects:matching_sessions(directory, sessions, host, picker_block)
  local matches, canonical = {}, { [directory] = directory }
  for _, session in ipairs(sessions) do
    local matched = self.R:with_session(session.session_id, function(view)
      for _, window in ipairs(view.windows or {}) do
        for _, layer in ipairs(window.layers or {}) do
          for _, block in ipairs(layer.blocks or {}) do
            if
              block.block_id ~= picker_block
              and block.creator_name == "com.superlogical.terminal"
              and nonempty(host)
              and block.host_id == host
            then
              local process = self.R:block_call(session.session_id, block.block_id, "process", {})
              local cwd = process.foreground and process.foreground.cwd
              if not cwd then
                for _, ancestor in ipairs(process.ancestors or {}) do
                  if ancestor.cwd then
                    cwd = ancestor.cwd
                    break
                  end
                end
              end
              if cwd then
                canonical[cwd] = canonical[cwd] or self.R:canonical_path(cwd)
                if canonical[cwd] == directory then
                  return true
                end
              end
            end
          end
        end
      end
      return false
    end)
    if matched then
      matches[#matches + 1] = session.session_id
    end
  end
  return matches
end

function Projects:project_label(directory, sessions)
  local base = text.project_base(directory:match("([^/]+)$") or directory)
  local occupied = {}
  for _, session in ipairs(sessions) do
    occupied[session.label] = true
  end
  if not occupied[base] then
    return base
  end
  local stem = base .. "-" .. self.R:sha256(directory):sub(1, 8)
  local label, count = stem, 2
  while occupied[label] do
    label, count = stem .. "-" .. count, count + 1
  end
  return label
end

function Projects:commit_open(request)
  local R, directory = self.R, request.directory
  assert(R:is_directory(directory), "Project directory no longer exists: " .. directory)
  local status = R:call("server.status", {})
  local endpoint = status.instance_id
  for _, listener in ipairs(status.listeners or {}) do
    if listener.primary then
      endpoint = listener.endpoint
      break
    end
  end
  assert(nonempty(endpoint), "Could not identify the local Rex server")
  local scope = (status.host_id or "") .. "|" .. endpoint
  local state = self:read_registry()
  state[scope] = state[scope] or json.object()
  local mapping, sessions, available = state[scope], R:call("session.list", {}).sessions or {}, {}
  for _, session in ipairs(sessions) do
    available[session.session_id] = true
  end
  local target = mapping[directory]
  if not available[target] then
    local matches = self:matching_sessions(directory, sessions, status.host_id, request.picker_block)
    assert(#matches <= 1, "Multiple Rex sessions have terminals in this directory; select one manually")
    if #matches == 1 then
      target = matches[1]
    else
      assert(R:is_directory(directory), "Project directory no longer exists: " .. directory)
      local result = R:call("session.create", {
        label = self:project_label(directory, sessions),
        initial_windows = {
          {
            window_label = "Terminal",
            layout = {
              block = {
                flavor = "com.superlogical.terminal.shell",
                options = { cwd = directory },
              },
            },
          },
        },
      })
      target = result and result.session_id
      assert(nonempty(target), "Rex did not return a session ID; inspect sessions before retrying creation")
    end
    mapping[directory] = target
    R:save_json(self:registry_path(), state)
  end
  return target
end

return M
