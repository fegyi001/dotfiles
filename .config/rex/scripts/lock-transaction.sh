#!/bin/sh
# Keep the kernel lock in the same process that executes the Lua transaction.
set -eu
wait_seconds=$1
lock=$2
shift 2
umask 077
/bin/mkdir -p "${lock%/*}"
exec 3>>"$lock"
if /usr/bin/lockf -s -t "$wait_seconds" 3; then
  export REX_PICKER_LOCKED=1
  exec "$@"
else
  status=$?
  if [ "$status" -eq 75 ]; then
    echo 'A session switch or project open is already in progress; wait before trying again' >&2
  fi
  exit "$status"
fi
