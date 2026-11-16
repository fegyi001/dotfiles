# Session switching

- **Ctrl+A, Space** opens an fzf session picker.
- **Ctrl+A, Shift+L** toggles the last two sessions selected through the session
  picker or project picker (**Ctrl+A, F**).

Reload through Rex's **Reload Config** command, or run `rex config reload`.
Then switch from session A to B with either picker. Press **Ctrl+A, Shift+L**
twice: it should return to A, then B.

The pickers need Python 3.9 or newer (`python3`), `fzf`, and `rex` on PATH.
The system Python included with the macOS command-line tools is supported.
The helper checks PATH first, then Rex's managed macOS installation and standard
local/Homebrew executable locations, since app-launched actions may have a minimal PATH.
Each session row includes its ID so duplicate labels can be distinguished.
Session selection uses
Rex Remote Control, which must be enabled in the app (the project picker
already required it). Errors from the toggle are reported by the Rex action;
picker errors remain in their tab until Enter is pressed.

## History and limits

`session-picker.py` stores session IDs (not names) in `session-history.json`
beside this configuration, or under `$XDG_CONFIG_HOME/rex` when set. History
is separated by host and client ID, written atomically under a file lock,
and ignored by Git. Renaming a session is safe. A new client ID, such as after
restarting the app, starts with no history: switch using a picker to seed it.

Cancelling the picker or selecting the current session leaves history alone.
If the remembered session was closed, or no history exists yet, the toggle
reports an error; choose another session with a picker to establish a new pair.
While a switch is in progress, another toggle reports a busy error instead of
queuing a second operation with a potentially stale source session. Wait for
the first switch to finish before toggling again.

Rex does not expose a selected-session-change event. Sidebar clicks, the native
session picker, and native next/previous actions do **not** update this history.
After such a switch, the toggle returns to the most recently tracked session,
then alternates with the session it was invoked from.

The helper operates on the local Rex server, matching the project picker;
multiple server instances sharing one configuration directory are not supported.
No background process is needed, and merely opening or cancelling either
picker does not record a switch.

## Tests

From the dotfiles root, run:

```sh
python3 -m unittest discover -s tests -v
rex config check .config/rex/init.lua
```

The suite uses temporary history files, fake external Rex/fzf responses, and a
Lua action harness (requires `lua`). It does not change live sessions.
