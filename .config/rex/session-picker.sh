#!/bin/sh
# Keep the session CLI stable while sharing Node resolution with the project picker.
set -eu
exec /bin/sh "${0%/*}/node.sh" "${0%/*}/session-picker.mjs" "$@"
