-- Private worker. The public picker launches this through lock-transaction.sh.
assert(os.getenv("REX_PICKER_LOCKED") == "1", "Transaction worker must hold its state lock")
local source = debug.getinfo(1, "S").source:gsub("^@", "")
local root = assert(source:match("^(.*)/scripts/[^/]+$"), "Could not locate Rex picker modules")
package.path = root .. "/?.lua;" .. root .. "/?/init.lua;" .. package.path
local R = require("lua.picker.runtime").new({ root = root })
local request = assert(rex.args.request, "Missing transaction request")
if rex.args.kind == "session" then
  return require("lua.picker.sessions").new(R):commit_switch(request)
elseif rex.args.kind == "project" then
  local S = require("lua.picker.sessions").new(R)
  return require("lua.picker.projects").new(R, S):commit_open(request)
end
error("Unknown transaction kind")
