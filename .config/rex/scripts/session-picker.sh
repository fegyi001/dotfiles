#!/bin/sh
# Preserve the original session CLI path while implementation lives in the plugin.
set -eu
exec /bin/sh "${0%/*}/../rex-navigation/scripts/session-picker.sh" "$@"
