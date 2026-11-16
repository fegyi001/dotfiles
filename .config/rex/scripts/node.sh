#!/bin/sh
# Run a Rex Node script without depending on login-shell Node/fnm setup.
set -eu

node_path=$(command -v node || true)
if [ -n "$node_path" ]; then
  exec "$node_path" "$@"
fi

for node_path in \
  "$HOME/.local/share/fnm/aliases/default/bin/node" \
  "$HOME/Library/Application Support/fnm/aliases/default/bin/node" \
  "$HOME/.local/bin/node" \
  /opt/homebrew/bin/node \
  /usr/local/bin/node
do
  if [ -f "$node_path" ] && [ -x "$node_path" ]; then
    exec "$node_path" "$@"
  fi
done

echo "rex-picker: Could not find Node.js; install Node.js or set a stable fnm default" >&2
exit 1
