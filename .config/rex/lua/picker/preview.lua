local json = require("lua.picker.json")
local text = require("lua.picker.text")
local M, Preview = {}, {}
Preview.__index = Preview
local function safe_integer(value)
  return type(value) == "number" and value >= 0 and value <= 9007199254740991 and value % 1 == 0
end
local function valid_id(value, prefix)
  return type(value) == "string" and value:match("^" .. prefix .. ":[%w:-]+$")
end
local function rows_value(value)
  value = tonumber(value)
  return value and safe_integer(value) and value > 0 and math.min(value, 200) or 24
end
function M.new(R)
  return setmetatable({ R = R }, Preview)
end

-- Preview RPCs use bounded CLI capture: native rex.call has no response-byte limit.
-- The outer supervisor bounds the total request chain, not each request separately.
function Preview:query(session, block, method, args)
  local argv = { self.R:command_path("rex"), "--autostart=false" }
  if block then
    for _, arg in ipairs({ "block", "call", "-s", session, "-b", block, method, json.encode(args) }) do
      argv[#argv + 1] = arg
    end
  else
    for _, arg in ipairs({ "api", "call", method, json.encode(args) }) do
      argv[#argv + 1] = arg
    end
  end
  local result = self.R:run(argv, { timeout = 2, max_stdout = 256 * 1024, max_stderr = 64 * 1024 })
  assert(result.ok, "Rex preview request failed")
  return json.decode(result.stdout)
end

function Preview:snapshot(session, rows)
  assert(valid_id(session, "session"), "Invalid session ID")
  rows = rows_value(rows)
  local view = self:query(session, nil, "session.view", { session_id = session })
  assert(json.is_object(view) and json.is_array(view.windows), "No session view")
  local active
  for _, window in ipairs(view.windows) do
    if window.window_id == view.active_window_id then
      active = window
      break
    end
  end
  assert(active, "No active window")
  local focused
  for _, layer in ipairs(active.layers or {}) do
    for _, block in ipairs(layer.blocks or {}) do
      if block.block_id == active.focused_block_id then
        focused = block
        break
      end
    end
  end
  assert(
    focused and focused.creator_name == "com.superlogical.terminal" and valid_id(focused.block_id, "block"),
    "No focused terminal"
  )
  local block = focused.block_id
  local modes = self:query(session, block, "modes", {})
  assert(json.is_object(modes) and type(modes.screen) == "string", "No terminal screen mode")
  local alternate = modes.screen == "alternate"
  local formatted = self:query(session, block, "format", { format = "text", trim = true, max_bytes = 4096 })
  assert(json.is_object(formatted) and type(formatted.content) == "string", "No terminal text")
  local value, truncated = formatted.content, false
  if formatted.id ~= nil then
    assert(
      safe_integer(formatted.id) and safe_integer(formatted.total) and formatted.total > 0,
      "Invalid snapshot metadata"
    )
    local offset = alternate and 0 or math.max(0, formatted.total - 32768)
    local blob = self:query(session, block, "blob_read", {
      id = formatted.id,
      offset = offset,
      max_bytes = alternate and 32768 or 32768 * 6,
    })
    assert(
      json.is_object(blob)
        and blob.id == formatted.id
        and blob.total == formatted.total
        and type(blob.eof) == "boolean"
        and (alternate or blob.eof)
        and type(blob.data) == "string",
      "Incomplete snapshot"
    )
    value = blob.data
    assert(#value <= 32768 + 3, "Snapshot too large")
    if alternate and not blob.eof then
      truncated = true
      value = value:match("^(.*\n)") or ""
    elseif offset > 0 then
      local newline = value:find("\n", 1, true)
      assert(newline, "No complete snapshot lines")
      value = value:sub(newline + 1)
    end
  else
    assert(formatted.eof ~= false and #value <= 32768, "Unbounded snapshot")
  end
  local safe = text.preview(value):gsub("\n+$", "")
  if safe == "" and not truncated then
    return "(Terminal is empty)"
  end
  local lines = {}
  if safe ~= "" then
    for line in (safe .. "\n"):gmatch("(.-)\n") do
      lines[#lines + 1] = line
    end
  end
  local output = {}
  if alternate then
    if truncated or #lines > 200 then
      for index = 1, math.min(199, #lines) do
        output[#output + 1] = lines[index]
      end
      output[#output + 1] = "[Preview truncated]"
      return table.concat(output, "\n")
    end
    return safe
  end
  for index = math.max(1, #lines - rows + 1), #lines do
    output[#output + 1] = lines[index]
  end
  return table.concat(output, "\n")
end

function Preview:run(session, rows)
  local ok, value = pcall(function()
    assert(valid_id(session, "session"), "Invalid session ID")
    self.R.host.sleep(0.075)
    local result = self.R:run(self.R:script_argv("snapshot", { session = session, rows = rows_value(rows) }), {
      timeout = 1.925,
      max_stdout = 256 * 1024,
      max_stderr = 64 * 1024,
    })
    assert(result.ok, "Preview worker unavailable")
    local output = json.decode(result.stdout)
    assert(type(output) == "string", "Invalid snapshot text")
    return output
  end)
  if not ok then
    if tostring(value):find("context canceled", 1, true) or tostring(value):find("interrupted", 1, true) then
      return
    end
    value = "Preview unavailable (no readable terminal or request timed out)."
  end
  io.write(value .. "\n")
end

return M
