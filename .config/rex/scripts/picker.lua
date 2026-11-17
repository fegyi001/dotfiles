local source = debug.getinfo(1, "S").source:gsub("^@", "")
local root = assert(source:match("^(.*)/scripts/[^/]+$"), "Could not locate Rex picker modules")
package.path = root .. "/?.lua;" .. root .. "/?/init.lua;" .. package.path
local function main()
  local R = require("lua.picker.runtime").new({ root = root })
  local S = require("lua.picker.sessions").new(R)
  local operation = os.getenv("REX_PICKER_OPERATION")
  local context = {
    client_id = os.getenv("REX_PICKER_CLIENT"),
    session_id = os.getenv("REX_PICKER_CURRENT") or os.getenv("REX_SESSION"),
  }
  if operation == "project" then
    local P = require("lua.picker.projects").new(R, S)
    local directory = os.getenv("REX_PICKER_DIRECTORY")
    if os.getenv("REX_PICKER_DIRECTORY_SET") == "1" then
      directory = directory or ""
    end
    if directory == nil then
      directory = P:pick(os.getenv("REX_PICKER_CONFIG"))
      if directory == nil then
        return
      end
    end
    return P:open(context, directory, os.getenv("REX_PICKER_TAB") == "1" and os.getenv("REX_BLOCK") or nil)
  end
  assert(operation == "pick" or operation == "toggle" or operation == "select", "Choose pick, toggle, or select")
  assert(
    context.client_id and context.client_id ~= "" and context.session_id and context.session_id ~= "",
    "--client and --current are required"
  )
  local target = os.getenv("REX_PICKER_SESSION")
  if operation == "select" then
    assert(target and target ~= "", "select requires --session")
  else
    assert(target == nil, "--session is only valid with select")
  end
  if operation == "pick" then
    target = S:pick(context)
    if target == nil then
      return
    end
  end
  return S:switch(context, target)
end
local ok, err = pcall(main)
if not ok then
  io.stderr:write("rex-navigation: " .. tostring(err) .. "\n")
  if os.getenv("REX_PICKER_TAB") == "1" then
    io.write("Press Enter to close the picker… ")
    io.flush()
    io.read("*l")
  end
  rex.stop(1)
end
