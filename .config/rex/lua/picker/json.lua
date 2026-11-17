-- Preserve JSON null and container shapes; use Rex only for scalar strings/numbers.
local M = { null = {} }
local object_mt, array_mt = {}, {}

function M.object(value)
  return setmetatable(value or {}, object_mt)
end
function M.array(value)
  return setmetatable(value or {}, array_mt)
end
function M.is_array(value)
  return type(value) == "table" and getmetatable(value) == array_mt
end
function M.is_object(value)
  return type(value) == "table" and value ~= M.null and not M.is_array(value)
end

function M.decode(source)
  assert(type(source) == "string", "Invalid JSON: expected text")
  local pos, length = 1, #source
  local parse
  local function invalid(message)
    error("Invalid JSON at byte " .. pos .. ": " .. message, 0)
  end
  local function ws()
    while source:sub(pos, pos):match("[ \t\r\n]") do
      pos = pos + 1
    end
  end
  local function scalar(token)
    local value, err = rex.json.decode(token)
    if err then
      invalid(tostring(err))
    end
    return value
  end
  local function string_value()
    local start = pos
    pos = pos + 1
    while pos <= length do
      local byte = source:byte(pos)
      if byte == 34 then
        pos = pos + 1
        return scalar(source:sub(start, pos - 1))
      elseif byte == 92 then
        pos = pos + 1
        local escape = source:sub(pos, pos)
        if escape == "u" then
          if not source:sub(pos + 1, pos + 4):match("^%x%x%x%x$") then
            invalid("invalid Unicode escape")
          end
          pos = pos + 4
        elseif not escape:match('^["\\/bfnrt]$') then
          invalid("invalid string escape")
        end
      elseif byte < 32 then
        invalid("control byte in string")
      end
      pos = pos + 1
    end
    invalid("unterminated string")
  end
  parse = function(depth)
    if depth > 128 then
      invalid("nesting limit exceeded")
    end
    ws()
    local char = source:sub(pos, pos)
    if char == '"' then
      return string_value()
    end
    if char == "{" or char == "[" then
      local object = char == "{"
      local close = object and "}" or "]"
      local value = object and M.object() or M.array()
      pos = pos + 1
      ws()
      if source:sub(pos, pos) == close then
        pos = pos + 1
        return value
      end
      local index = 1
      while true do
        local key = index
        if object then
          ws()
          if source:sub(pos, pos) ~= '"' then
            invalid("object key must be a string")
          end
          key = string_value()
          ws()
          if source:sub(pos, pos) ~= ":" then
            invalid("missing colon")
          end
          pos = pos + 1
        end
        value[key] = parse(depth + 1)
        index = index + 1
        ws()
        char = source:sub(pos, pos)
        pos = pos + 1
        if char == close then
          return value
        end
        if char ~= "," then
          invalid("missing comma or closing delimiter")
        end
      end
    end
    for token, value in pairs({ ["true"] = true, ["false"] = false, ["null"] = M.null }) do
      if source:sub(pos, pos + #token - 1) == token then
        pos = pos + #token
        return value
      end
    end
    local token = source:sub(pos):match("^%-?%d+%.?%d*[eE]?[%+%-]?%d*")
    if token then
      local value = scalar(token)
      if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then
        invalid("invalid number")
      end
      pos = pos + #token
      return value
    end
    invalid("expected a value")
  end
  local result = parse(0)
  ws()
  if pos <= length then
    invalid("trailing content")
  end
  return result
end

function M.encode(value)
  local seen = {}
  local function encode(item, depth)
    assert(depth <= 128, "JSON nesting limit exceeded")
    if item == M.null then
      return "null"
    end
    local kind = type(item)
    if kind == "string" or kind == "boolean" or kind == "number" then
      if kind == "number" then
        assert(item == item and math.abs(item) ~= math.huge, "Invalid JSON number")
      end
      return rex.json.encode(item)
    end
    assert(kind == "table", "Unsupported JSON value: " .. kind)
    assert(not seen[item], "Cyclic JSON value")
    seen[item] = true
    local array = M.is_array(item)
    if getmetatable(item) == nil and next(item) ~= nil then
      array = true
      for key in pairs(item) do
        if type(key) ~= "number" then
          array = false
          break
        end
      end
    end
    local parts = {}
    if array then
      local count = 0
      for key in pairs(item) do
        assert(type(key) == "number" and key % 1 == 0 and key > 0 and key <= #item, "Invalid JSON array key")
        count = count + 1
      end
      assert(count == #item, "Sparse JSON array")
      for _, child in ipairs(item) do
        parts[#parts + 1] = encode(child, depth + 1)
      end
    else
      local keys = {}
      for key in pairs(item) do
        assert(type(key) == "string", "Invalid JSON object key")
        keys[#keys + 1] = key
      end
      table.sort(keys)
      for _, key in ipairs(keys) do
        parts[#parts + 1] = rex.json.encode(key) .. ":" .. encode(item[key], depth + 1)
      end
    end
    seen[item] = nil
    return (array and "[" or "{") .. table.concat(parts, ",") .. (array and "]" or "}")
  end
  return encode(value, 0)
end

return M
