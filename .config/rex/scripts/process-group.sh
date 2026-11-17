#!/bin/sh
# Supervise a bounded noninteractive worker, including its descendants (macOS).
# Interactive fzf does not use this adapter: it must own the foreground terminal.
set -m
child=
guard=
cancelled=
completed=false
owner=$PPID
supervisor=$$
cleanup() {
  trap '' TERM INT HUP
  if [ -n "$child" ]; then
    /bin/kill -TERM -- "-$child" 2>/dev/null || :
    # A completed command needs no cancellation grace. Its remaining descendants,
    # if any, must not outlive the finished work; only cancellation gets a grace.
    if [ "$completed" = false ]; then /bin/sleep 0.05; fi
    /bin/kill -KILL -- "-$child" 2>/dev/null || :
    wait "$child" 2>/dev/null || :
  fi
  if [ -n "$guard" ]; then
    # The guard owns no state. Do not wait for its current liveness-check sleep.
    kill -KILL "$guard" 2>/dev/null || :
    wait "$guard" 2>/dev/null || :
  fi
}
trap cleanup EXIT
trap 'cancelled=143' TERM
trap 'cancelled=130' INT
trap 'cancelled=129' HUP
"$@" <&0 &
child=$!
if [ -n "$cancelled" ]; then exit "$cancelled"; fi
# Rex can exit without delivering its direct-child cleanup under cancellation.
# This short-lived guard owns no application state and dies with this command.
(
  trap - EXIT TERM INT HUP
  while kill -0 "$owner" 2>/dev/null && kill -0 "$supervisor" 2>/dev/null; do /bin/sleep 0.05; done
  /bin/kill -TERM -- "-$child" 2>/dev/null || :
  /bin/sleep 0.05
  /bin/kill -KILL -- "-$child" 2>/dev/null || :
) </dev/null >/dev/null 2>&1 &
guard=$!
wait "$child"
status=$?
if [ -z "$cancelled" ]; then completed=true; fi
exit "${cancelled:-$status}"
