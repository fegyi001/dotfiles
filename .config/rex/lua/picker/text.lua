local ranges = require("lua.picker.text-data")
local M = {}
local replacement = "\239\191\189"
local function join(parts)
  -- Rex's Lua table.concat can overflow its VM registry with one entry per byte.
  while #parts > 512 do
    local chunks = {}
    for start = 1, #parts, 512 do
      chunks[#chunks + 1] = table.concat(parts, "", start, math.min(start + 511, #parts))
    end
    parts = chunks
  end
  return table.concat(parts)
end

local function decode(value, pos)
  local first = value:byte(pos)
  if first < 128 then
    return first, pos + 1, value:sub(pos, pos)
  end
  local count = first >= 194 and first <= 223 and 2
    or first >= 224 and first <= 239 and 3
    or first >= 240 and first <= 244 and 4
    or 0
  if count == 0 then
    return 65533, pos + 1, replacement
  end
  local cp = first % (2 ^ (7 - count))
  for index = pos + 1, pos + count - 1 do
    local byte = value:byte(index)
    if not byte or byte < 128 or byte > 191 then
      return 65533, pos + 1, replacement
    end
    cp = cp * 64 + byte - 128
  end
  if cp < ({ [2] = 128, [3] = 2048, [4] = 65536 })[count] or cp > 1114111 or (cp >= 55296 and cp <= 57343) then
    return 65533, pos + 1, replacement
  end
  return cp, pos + count, value:sub(pos, pos + count - 1)
end

local function contains(list, cp)
  local low, high = 1, #list / 2
  while low <= high do
    local middle = math.floor((low + high) / 2)
    if cp < list[middle * 2 - 1] then
      high = middle - 1
    elseif cp > list[middle * 2] then
      low = middle + 1
    else
      return true
    end
  end
  return false
end

function M.truncate_utf8(value, bytes)
  local parts, size, pos = {}, 0, 1
  while pos <= #value do
    local _, next_pos, char = decode(value, pos)
    if size + #char > bytes then
      break
    end
    parts[#parts + 1], size, pos = char, size + #char, next_pos
  end
  return join(parts)
end

local function clean_label(value, project)
  local parts, pos = {}, 1
  while pos <= #value do
    local cp, next_pos, char = decode(value, pos)
    local unsafe = contains(ranges.control, cp)
      or cp == 8232
      or cp == 8233
      or (project and cp ~= 32 and contains(ranges.separator, cp))
    parts[#parts + 1], pos = unsafe and " " or char, next_pos
  end
  return join(parts)
end

function M.session_label(value)
  return clean_label(value, false)
end

function M.project_base(value)
  local base = clean_label(value, true):gsub("^%s+", ""):gsub("%s+$", "")
  if base == "" then
    base = "project"
  end
  if base:sub(1, 1) == "-" then
    base = "project-" .. base
  end
  return M.truncate_utf8(base, 100)
end

local function skip_csi(value, pos)
  while pos <= #value do
    local byte = value:byte(pos)
    pos = pos + 1
    if byte >= 64 and byte <= 126 then
      return pos
    end
  end
  return pos
end

local function skip_string(value, pos, bell)
  while pos <= #value do
    local byte = value:byte(pos)
    if bell and byte == 7 then
      return pos + 1
    end
    if byte == 27 and value:byte(pos + 1) == 92 then
      return pos + 2
    end
    if byte == 156 then
      return pos + 1
    end
    if byte == 194 and value:byte(pos + 1) == 156 then
      return pos + 2
    end
    if byte >= 194 then
      local _, next_pos = decode(value, pos)
      pos = next_pos
    else
      pos = pos + 1
    end
  end
  return pos
end

function M.preview(value)
  local parts, pos = {}, 1
  while pos <= #value do
    local byte = value:byte(pos)
    if byte == 27 then
      local next_byte = value:byte(pos + 1)
      pos = pos + 2
      if next_byte == 91 then
        pos = skip_csi(value, pos)
      elseif next_byte == 93 then
        pos = skip_string(value, pos, true)
      elseif next_byte == 80 or next_byte == 88 or next_byte == 94 or next_byte == 95 then
        pos = skip_string(value, pos, false)
      elseif next_byte and next_byte >= 32 and next_byte <= 47 then
        while value:byte(pos) and value:byte(pos) >= 32 and value:byte(pos) <= 47 do
          pos = pos + 1
        end
        if value:byte(pos) then
          pos = pos + 1
        end
      end
    else
      local cp, next_pos, char
      if byte >= 128 and byte <= 159 then
        cp, next_pos = byte, pos + 1
      else
        cp, next_pos, char = decode(value, pos)
      end
      pos = next_pos
      if cp == 155 then
        pos = skip_csi(value, pos)
      elseif cp == 157 then
        pos = skip_string(value, pos, true)
      elseif cp == 144 or cp == 152 or cp == 158 or cp == 159 then
        pos = skip_string(value, pos, false)
      elseif cp == 13 then
        parts[#parts + 1] = "\n"
        if value:byte(pos) == 10 then
          pos = pos + 1
        end
      elseif cp == 9 or cp == 10 or (cp >= 32 and not (cp >= 127 and cp <= 159)) then
        parts[#parts + 1] = char
      end
    end
  end
  return join(parts)
end

return M
