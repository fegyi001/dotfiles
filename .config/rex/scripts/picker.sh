#!/bin/sh
# String-preserving bootstrap for Rex's embedded Lua. No shell startup files.
set -eu
set -f
kind=${1-}
if [ "$#" -gt 0 ]; then shift; fi
die() { echo "rex-navigation: $*" >&2; exit 1; }
usage() {
  if [ "$kind" = session ]; then
    echo 'Usage: session-picker.sh {pick,toggle,select} --client CLIENT --current SESSION [--session TARGET] [--picker-tab]'
  else
    echo 'Usage: rex-project-picker [DIRECTORY] [--config FILE] [--client CLIENT] [--picker-tab]'
  fi
  exit 0
}
unset REX_PICKER_OPERATION REX_PICKER_CLIENT REX_PICKER_CURRENT REX_PICKER_SESSION
unset REX_PICKER_DIRECTORY REX_PICKER_DIRECTORY_SET REX_PICKER_CONFIG REX_PICKER_TAB REX_PICKER_LOCKED
case "$kind" in
  session)
    case "${1-}" in
      -h|--help) usage ;;
      pick|toggle|select) REX_PICKER_OPERATION=$1; shift ;;
      *) die 'Choose pick, toggle, or select' ;;
    esac ;;
  project) REX_PICKER_OPERATION=project ;;
  *) die 'Choose session or project' ;;
esac
export REX_PICKER_OPERATION
set_option() {
  case "$1" in
    --client) REX_PICKER_CLIENT=$2; export REX_PICKER_CLIENT ;;
    --current) REX_PICKER_CURRENT=$2; export REX_PICKER_CURRENT ;;
    --session) [ "$kind" = session ] || die 'Unknown option --session'; REX_PICKER_SESSION=$2; export REX_PICKER_SESSION ;;
    --config) [ "$kind" = project ] || die 'Unknown option --config'; REX_PICKER_CONFIG=$2; export REX_PICKER_CONFIG ;;
    *) die "Unknown option $1" ;;
  esac
}
directory_set=false
positional() {
  [ "$kind" = project ] && [ "$directory_set" = false ] || die 'Expected at most one project directory'
  REX_PICKER_DIRECTORY=$1
  REX_PICKER_DIRECTORY_SET=1
  export REX_PICKER_DIRECTORY REX_PICKER_DIRECTORY_SET
  directory_set=true
}
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage ;;
    --picker-tab) REX_PICKER_TAB=1; export REX_PICKER_TAB; shift ;;
    --) shift; while [ "$#" -gt 0 ]; do positional "$1"; shift; done ;;
    --*=*) option=${1%%=*}; value=${1#*=}; set_option "$option" "$value"; shift ;;
    --client|--current|--session|--config)
      [ "$#" -ge 2 ] || die "Missing value for $1"
      case "$2" in -?*) die "Missing or ambiguous value for $1; use $1=VALUE for a leading dash" ;; esac
      set_option "$1" "$2"; shift 2 ;;
    -) positional "$1"; shift ;;
    -*) die "Unknown option $1" ;;
    *) positional "$1"; shift ;;
  esac
done
if [ "$kind" = session ]; then
  [ -n "${REX_PICKER_CLIENT-}" ] && [ -n "${REX_PICKER_CURRENT-}" ] || die '--client and --current are required'
  if [ "$REX_PICKER_OPERATION" = select ]; then
    [ -n "${REX_PICKER_SESSION-}" ] || die 'select requires --session'
  else
    [ "${REX_PICKER_SESSION+x}" != x ] || die '--session is only valid with select'
  fi
fi
script_dir=$(CDPATH= cd -- "${0%/*}" && pwd -P)
root=${script_dir%/scripts}
rex_command=
old_ifs=$IFS
IFS=:
for directory in ${PATH-}; do
  if [ -f "$directory/rex" ] && [ -x "$directory/rex" ]; then rex_command=$directory/rex; break; fi
done
IFS=$old_ifs
if [ -z "$rex_command" ]; then
  for directory in \
    "$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS" \
    "$HOME/.local/bin" /opt/homebrew/bin /usr/local/bin \
    '/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS'; do
    if [ -f "$directory/rex" ] && [ -x "$directory/rex" ]; then rex_command=$directory/rex; break; fi
  done
fi
[ -n "$rex_command" ] || die "Could not find rex; install it or add its directory to Rex's PATH"
unset REX_SERVER
exec "$rex_command" --autostart=false do "$root/scripts/picker.lua"
