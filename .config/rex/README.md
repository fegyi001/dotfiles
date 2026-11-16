# Session switching

## Layout

```text
rex/
├── init.lua             # Rex entrypoint; loads lua/ modules
├── projects.json        # Editable project roots and exclusions
├── README.md
├── lua/                 # Keybindings and custom Rex actions
│   ├── keys.lua
│   ├── navigation.lua
│   ├── projects.lua
│   ├── sessions.lua
│   └── tabs.lua
├── scripts/             # Node.js helpers and shell launchers
│   ├── node.sh
│   ├── project-picker.mjs
│   ├── rex-runtime.mjs
│   ├── session-picker.mjs
│   └── session-picker.sh
└── state/               # Git-ignored runtime data
    ├── session-history.json
    └── session-history.lock
```

The root also contains Git/editor settings. Reload Rex after changing Lua module
locations; the public `rex-project-picker` command remains at the same path.

## Shortcuts and requirements

- **Ctrl+A, Space** opens an fzf session picker.
- **Ctrl+A, Shift+L** toggles the last two sessions selected through the session
  picker or project picker (**Ctrl+A, F**).

Reload through Rex's **Reload Config** command, or run `rex config reload`.
Then switch from session A to B with either picker. Press **Ctrl+A, Shift+L**
twice: it should return to A, then B.

Both pickers use Node.js 20 or newer, `fzf`, `rex`, and macOS's built-in
`/usr/bin/lockf`. No Python, npm packages, or build step are needed.

The launchers share `scripts/node.sh`, which checks PATH for Node, then stable fnm default
aliases and standard local/Homebrew locations. The shared Node runtime checks Rex's managed
macOS installation and local/Homebrew locations for Rex/fzf, since app-launched
actions may have a minimal PATH. It does not source shell startup files.
Each session row includes its ID so duplicate labels can be distinguished.
Session selection uses
Rex Remote Control, which must be enabled in the app (the project picker
already required it). Errors from the toggle are reported by the Rex action;
picker errors remain in their tab until Enter is pressed.

## History and limits

`scripts/session-picker.mjs` stores session IDs (not names) in
`state/session-history.json` under this configuration directory, or under
`$XDG_CONFIG_HOME/rex/state` when set. Existing root-level history was moved there
without changing its contents. History is separated by host, written atomically
under a file lock, and ignored by Git. All apps connected to the same host share
one last-used pair, so restarting the app or changing its connection ID does not
reset history. The current client ID is used only to address the connected app.
Kernel locking uses the same lock file and automatically releases when the helper
exits. Renaming a session is safe.

New pairs are saved as the host's `shared` entry. Older per-client entries,
including Python-created history, are retained. Before a shared entry exists,
the toggle recovers an old pair only when it contains the invoking session and
all eligible pairs agree on one still-existing destination. Conflicting histories
require a picker selection rather than guessing which is newest. Recovery is
saved only after a successful switch; no standalone migration is needed. Once a
shared entry exists it is authoritative, even if its remembered session closes.

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

## Project directories

**Ctrl+A, F** uses `scripts/project-picker.mjs` through the existing
`~/.local/bin/rex-project-picker` command. It reads `projects.json` beside this
configuration (or pass `--config FILE` when using the command directly).
Roots accept absolute paths or `~/...`; their depth limits traversal.
Hidden directories, excluded directory names, files, and directory symlinks are
not offered. Overlapping roots are canonicalized and deduplicated.

The picker reuses the project/session associations in
`$XDG_STATE_HOME/rex/project-sessions.json` (default `~/.local/state/rex`).
Existing Python-created associations are read without conversion. If an association
is stale or missing, local terminal working directories are checked before a new
session is created; ambiguous matches require manual selection. Creation and
registry updates are locked to avoid duplicate sessions during concurrent opens.
Project opens wait up to 20 seconds for the registry lock rather than wait indefinitely.
An association survives a refused switch, so retrying does not duplicate the session.

To open a directory directly:

```sh
rex-project-picker ~/code/my-project
```

## Tests

From the dotfiles root, run:

```sh
node --test tests/*.test.mjs
rex config check .config/rex/init.lua
```

The Node suites run the real pickers and launchers against fake Rex/fzf executables,
temporary project trees, and temporary state files, including real kernel-lock
contention and GUI PATH checks. A Lua action harness requires `lua` for the
configuration integration test. Tests do not create or switch live sessions.
