#!/bin/sh
# Keep the session CLI stable while using Rex's embedded Lua.
set -eu
exec /bin/sh "${0%/*}/picker.sh" session "$@"
