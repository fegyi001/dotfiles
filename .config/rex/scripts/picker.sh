#!/bin/sh
# Compatibility bridge for actions loaded before the navigation extraction.
set -eu
exec /bin/sh "${0%/*}/../rex-navigation/scripts/navigation.sh" "$@"
