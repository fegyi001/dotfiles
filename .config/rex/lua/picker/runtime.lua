-- Shared macOS runtime for Rex-hosted pickers. Loading this module has no side effects.
local M = {}
local Runtime = {}
Runtime.__index = Runtime

function M.new(options)
  assert(type(options.root) == "string" and options.root ~= "", "Picker root is required")
  return setmetatable({ root = options.root, host = options.host or rex }, Runtime)
end

function Runtime:call(method, args)
  local value, err = self.host.call(method, args or {})
  if err then
    error(method .. ": " .. tostring(err), 0)
  end
  return value
end

function Runtime:block_call(session_id, block_id, method, args)
  local request = {}
  for key, value in pairs(args or {}) do
    request[key] = value
  end
  request.session_id, request.block_id = session_id, block_id
  local value, err = self.host.block.call("com.superlogical.terminal", method, request)
  if err then
    error(method .. ": " .. tostring(err), 0)
  end
  return value
end

function Runtime:with_session(session_id, inspect)
  assert(type(session_id) == "string" and session_id:match("^session:[%w:-]+$"), "Invalid session ID")
  local attachment, attach_error = self.host.session.attach({ session_id = session_id })
  assert(attachment, attach_error or "Could not attach the inspection stream")
  local ok, value = pcall(function()
    local view = attachment.view
    if not view then
      local err
      view, err = self.host.session.view({ session_id = session_id })
      assert(view, err or "Could not inspect session")
    end
    return inspect(view)
  end)
  local detached_ok, detached, detach_error = pcall(self.host.session.detach, { session_id = session_id })
  if not ok then
    error(value, 0)
  end
  assert(detached_ok and detached, detach_error or "Could not detach the inspection stream")
  return value
end

function Runtime:command_path(name)
  assert(name:match("^[%w_.-]+$"), "Invalid executable name")
  local home = assert(os.getenv("HOME"), "HOME is not set")
  local directories = {}
  for directory in (os.getenv("PATH") or ""):gmatch("[^:]+") do
    directories[#directories + 1] = directory
  end
  if name == "rex" then
    directories[#directories + 1] = home
      .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS"
  end
  for _, directory in ipairs({ home .. "/.local/bin", "/opt/homebrew/bin", "/usr/local/bin" }) do
    directories[#directories + 1] = directory
  end
  if name == "rex" then
    directories[#directories + 1] = "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS"
  end
  local argv = {
    "/bin/sh",
    "-c",
    'name=$1; shift; for dir do file="$dir/$name"; '
      .. 'if [ -f "$file" ] && [ -x "$file" ]; then printf "%s" "$file"; exit 0; fi; done; exit 1',
    "sh",
    name,
  }
  for _, directory in ipairs(directories) do
    argv[#argv + 1] = directory
  end
  local result, err = self.host.exec(argv, { timeout = 2 })
  assert(result, err or "Could not locate " .. name)
  assert(result.ok, "Could not find " .. name .. "; install it or add its directory to Rex's PATH")
  return result.stdout
end

function Runtime:script_argv(name, args)
  assert(name:match("^[%w-]+$"), "Invalid picker script name")
  return {
    self:command_path("rex"),
    "--autostart=false",
    "do",
    self.root .. "/scripts/" .. name .. ".lua",
    "--args",
    self.host.json.encode(args),
  }
end

function Runtime:select_client(client_id, target)
  local result = self:run({
    self:command_path("rex"),
    "--autostart=false",
    "-C",
    client_id,
    "do",
    "session.select",
    "session_id=" .. target,
  })
  assert(result.ok, result.stderr ~= "" and result.stderr or "Could not switch session")
end

function Runtime:read_json(path, missing_value)
  local file, err = io.open(path, "r")
  if not file then
    if tostring(err):match("no such file or directory$") then
      return missing_value
    end
    error(tostring(err), 0)
  end
  local source = file:read(8 * 1024 * 1024 + 1) or ""
  file:close()
  assert(#source <= 8 * 1024 * 1024, "JSON state is too large: " .. path)
  return require("lua.picker.json").decode(source)
end

function Runtime:save_json(path, value)
  local encoded = require("lua.picker.json").encode(value) .. "\n"
  local directory = assert(path:match("^(.*)/[^/]+$"), "State path needs a parent directory")
  local created = self:run({
    "/bin/sh",
    "-c",
    'umask 077; /bin/mkdir -p "$1" && exec /usr/bin/mktemp "$1/.rex-state.XXXXXX"',
    "sh",
    directory,
  })
  assert(created.ok, created.stderr)
  local temporary = created.stdout:gsub("\n$", "")
  assert(temporary ~= "", "Could not allocate temporary state file")
  local file
  local ok, err = pcall(function()
    local open_error
    file, open_error = io.open(temporary, "w")
    assert(file, open_error)
    assert(file:write(encoded))
    assert(file:close())
    file = nil
    local synced = self:run({ "/bin/dd", "if=/dev/null", "of=" .. temporary, "conv=notrunc,fsync", "status=none" })
    assert(synced.ok, synced.stderr)
    assert(os.rename(temporary, path))
  end)
  if file then
    pcall(function()
      file:close()
    end)
  end
  if not ok then
    os.remove(temporary)
    error(err, 0)
  end
end

function Runtime:transaction(kind, request, wait_seconds)
  assert(kind == "session" or kind == "project", "Invalid transaction kind")
  assert(
    type(wait_seconds) == "number" and wait_seconds >= 0 and wait_seconds <= 20 and wait_seconds % 1 == 0,
    "Invalid lock wait"
  )
  local home = assert(os.getenv("HOME"), "HOME is not set")
  local path
  if kind == "session" then
    path = (os.getenv("XDG_CONFIG_HOME") or home .. "/.config") .. "/rex/state/session-history.lock"
  else
    path = (os.getenv("XDG_STATE_HOME") or home .. "/.local/state") .. "/rex/project-sessions.lock"
  end
  local argv = { "/bin/sh", self.root .. "/scripts/lock-transaction.sh", tostring(wait_seconds), path }
  for _, arg in ipairs(self:script_argv("transaction", { kind = kind, request = request })) do
    argv[#argv + 1] = arg
  end
  -- The exec'd Lua worker owns its lock descriptor. Individual RPCs remain bounded;
  -- directory/session matching has no new whole-transaction time limit.
  local result = self:run(argv, { timeout = false, env = { REX_PICKER_LOCKED = false } })
  assert(result.ok, result.stderr ~= "" and result.stderr or "Picker transaction failed")
  if result.stdout:match("%S") then
    return require("lua.picker.json").decode(result.stdout)
  end
end

function Runtime:is_directory(path)
  return self:run({ "/bin/test", "-d", path }).ok
end

function Runtime:canonical_path(path)
  local expanded = path
  if path == "~" or path:sub(1, 2) == "~/" then
    expanded = assert(os.getenv("HOME")) .. path:sub(2)
  end
  -- BSD realpath has no -- terminator; prefix relative arguments to prevent options.
  local candidate = expanded:sub(1, 1) == "/" and expanded or "./" .. expanded
  local result = self:run({ "/bin/realpath", candidate })
  if result.ok then
    return result.stdout:gsub("\n$", "")
  end
  if not result.stderr:lower():find("no such file", 1, true) then
    error(result.stderr, 0)
  end
  if expanded:sub(1, 1) ~= "/" then
    local cwd = self:run({ "/bin/pwd", "-P" })
    assert(cwd.ok, cwd.stderr)
    expanded = cwd.stdout:gsub("\n$", "") .. "/" .. expanded
  end
  local parts = {}
  for part in expanded:gmatch("[^/]+") do
    if part == ".." then
      parts[#parts] = nil
    elseif part ~= "." then
      parts[#parts + 1] = part
    end
  end
  return "/" .. table.concat(parts, "/")
end

function Runtime:discover(roots, exclude)
  local found = {}
  for _, root in ipairs(roots) do
    if not self:is_directory(root.path) then
      io.stderr:write("Warning: skipping missing root " .. root.path .. "\n")
    else
      local path = self:canonical_path(root.path)
      local argv = { "/usr/bin/find", path, "-mindepth", "1", "-maxdepth", tostring(root.depth), "(", "-name", ".*" }
      for _, name in ipairs(exclude) do
        argv[#argv + 1], argv[#argv + 2], argv[#argv + 3] = "-o", "-name", name:gsub("([*?%[\\])", "\\%1")
      end
      for _, arg in ipairs({ ")", "-prune", "-o", "-type", "d", "-print0" }) do
        argv[#argv + 1] = arg
      end
      local result = self:run(argv, { timeout = 30 })
      if not result.ok then
        io.stderr:write("Warning: cannot read " .. path .. ": " .. result.stderr .. "\n")
      end
      for directory in result.stdout:gmatch("([^%z]+)%z") do
        found[directory] = true
      end
    end
  end
  local paths = {}
  for path in pairs(found) do
    paths[#paths + 1] = path
  end
  table.sort(paths)
  return paths
end

function Runtime:sha256(value)
  local result = self:run({ "/usr/bin/openssl", "dgst", "-sha256" }, { stdin = value })
  assert(result.ok, result.stderr)
  local hash = result.stdout:match("(%x+)%s*$")
  assert(hash and #hash == 64, "Invalid SHA-256 response")
  return hash:lower()
end

function Runtime:sort_labels(records)
  local ordered, input = {}, {}
  for _, record in ipairs(records) do
    ordered[#ordered + 1] = record
  end
  table.sort(ordered, function(a, b)
    return a.id < b.id
  end)
  for index, record in ipairs(ordered) do
    assert(not record.label:find("[%z\t\r\n]"), "Unsafe display label")
    input[#input + 1] = index .. "\t" .. record.label .. "\n"
  end
  if #ordered == 0 then
    return ordered
  end
  local result = self:run({ "/usr/bin/sort", "-s", "-f", "-t", "\t", "-k2,2" }, {
    stdin = table.concat(input),
    env = { LC_ALL = "en_US.UTF-8" },
  })
  assert(result.ok, result.stderr)
  local sorted = {}
  for index in result.stdout:gmatch("(%d+)\t[^\n]*\n") do
    sorted[#sorted + 1] = assert(ordered[tonumber(index)])
  end
  assert(#sorted == #ordered, "Incomplete sorted session list")
  return sorted
end

function Runtime:picker_env()
  local result = self:run({ "/usr/bin/env", "-0" })
  assert(result.ok, "Could not isolate fzf environment")
  local env = { SHELL = "/bin/sh" }
  for record in result.stdout:gmatch("([^%z]+)%z") do
    local key = record:match("^([^=]+)=")
    if key and key:sub(1, 4) == "FZF_" then
      env[key] = false
    end
  end
  return env
end

function Runtime:run(argv, options)
  options = options or {}
  local timeout = options.timeout
  if timeout == nil then
    timeout = 10
  end
  local limits = { stdout = options.max_stdout or 8 * 1024 * 1024, stderr = options.max_stderr or 256 * 1024 }
  local chunks, sizes = { stdout = {}, stderr = {} }, { stdout = 0, stderr = 0 }
  local child, overflow
  local function receive(stream)
    return function(chunk)
      if overflow then
        return
      end
      if sizes[stream] + #chunk > limits[stream] then
        overflow = stream .. " exceeded its output limit"
        if child then
          child:kill("SIGTERM")
        end
        return
      end
      sizes[stream] = sizes[stream] + #chunk
      chunks[stream][#chunks[stream] + 1] = chunk
    end
  end
  local command = argv
  -- fzf must stay in the foreground to read its terminal. Bounded workers get a
  -- separate process group so Rex's direct-child cleanup also reaps descendants.
  if timeout ~= false then
    command = { "/bin/sh", self.root .. "/scripts/process-group.sh" }
    for _, arg in ipairs(argv) do
      command[#command + 1] = arg
    end
  end
  local env = {}
  for key, value in pairs(options.env or {}) do
    env[key] = value
  end
  env.REX_SERVER = false
  local err
  child, err = self.host.exec.start(command, {
    cwd = options.cwd,
    env = env,
    clear_env = options.clear_env,
    stdin = options.stdin,
    stdout = receive("stdout"),
    stderr = receive("stderr"),
  })
  assert(child, err or "Could not start picker subprocess")
  local result, wait_error
  if timeout == false then
    result, wait_error = child:wait()
  else
    result, wait_error = child:wait(timeout)
  end
  local timed_out = not result and wait_error == "timeout"
  if not result then
    child:kill("SIGTERM")
    -- On script cancellation, waits can return immediately with a context error.
    -- Do not mistake that for an elapsed grace period and kill the group supervisor
    -- before its TERM trap can clean up descendants.
    if wait_error ~= "timeout" then
      error(wait_error or "Picker subprocess canceled", 0)
    end
    result, wait_error = child:wait(options.kill_grace or 0.1)
    if not result and wait_error == "timeout" then
      child:kill("SIGKILL")
      result, wait_error = child:wait(1)
    end
  end
  assert(result, wait_error or "Could not reap picker subprocess")
  if overflow then
    error(overflow, 0)
  end
  return {
    code = result.code,
    ok = result.ok and not timed_out,
    stdout = table.concat(chunks.stdout),
    stderr = table.concat(chunks.stderr),
    signal = result.signal,
    timed_out = timed_out,
  }
end

return M
