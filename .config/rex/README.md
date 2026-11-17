# Rex navigation

Session/project pickers, last-used switching, and read-only terminal previews.
All navigation logic runs in **Rex's embedded Lua**, with fzf for the interface.
No Node.js, standalone Lua installation, npm packages, or build step is needed
to use it. This is a local Lua extension, not an official Rex plugin format.

## Layout

```text
rex/
├── init.lua             # Rex entrypoint; loads lua/ modules
├── projects.json        # Editable project roots and exclusions
├── README.md
├── lua/                 # Keybindings and custom Rex actions
│   ├── keys.lua
│   ├── navigation.lua
│   ├── picker/           # Importable navigation module
│   │   ├── init.lua      # setup(): register actions, no bindings
│   │   ├── sessions.lua  # Picker ordering and shared history
│   │   ├── projects.lua  # Project discovery and session reuse/creation
│   │   ├── preview.lua   # Bounded read-only snapshots
│   │   ├── runtime.lua   # Rex/process/filesystem adapters
│   │   ├── json.lua      # Strict state/config JSON handling
│   │   ├── text.lua      # UTF-8 and terminal-control sanitation
│   │   └── text-data.lua # Checked-in Unicode property ranges
│   └── tabs.lua
├── scripts/             # Short-lived Lua workers and POSIX bootstraps
│   ├── picker.sh         # CLI parsing and Rex lookup
│   ├── picker.lua        # Session/project dispatch and errors
│   ├── transaction.lua  # Locked state-changing worker
│   ├── lock-transaction.sh
│   ├── process-group.sh # Bounded worker/descendant cleanup
│   ├── session-preview.lua
│   ├── snapshot.lua
│   └── session-picker.sh # Compatible session CLI entrypoint
└── state/               # Git-ignored runtime data
    ├── session-history.json
    └── session-history.lock
```

The root also contains Git/editor settings. The public `rex-project-picker`
command remains at the same path.

## Loading and packaging

The host `init.lua` loads the navigation actions with:

```lua
require("lua.picker").setup()
```

Requiring the module alone has no effects. `setup()` registers
`open_session_picker`, `open_project_picker`, and `last_used_session`; the host's
`lua/keys.lua` owns bindings. Call setup once per configuration load. An optional
`{ root = "/absolute/path" }` overrides code-root discovery.

Code and workers resolve their paths relative to their own root, not the current
working directory. State and editable project roots stay in the host's XDG paths,
outside the code root. A separate `rex-navigation` repository/submodule is planned
only after this migration has been verified; none is created automatically.
With the same `lua/picker/` and `scripts/` layout below a future
`~/.config/rex/rex-navigation` submodule, the host import would be:

```lua
require("rex-navigation.lua.picker").setup()
```

The command wrapper's install path would also need to point to that submodule's
`scripts/picker.sh`; the current Stow-managed wrapper targets this host layout.
No plugin manager or future Rex plugin API is assumed.

## Shortcuts and requirements

- **Ctrl+A, Space** opens an fzf session picker in a focused floating pane over
  the invoking tab, centered at 70% of its width and 60% of its height. It creates
  no temporary tab. The current session is excluded; the last-used destination
  comes first, marked `(last used)`, followed by other sessions alphabetically,
  ignoring case. The left half lists sessions; the right half
  previews a terminal text snapshot. Typing ranks matches by fuzzy relevance;
  clearing the query restores last-used-first order.
  Esc cancels and closes the pane; selecting a session switches and closes it.
- **Ctrl+A, F** opens the project picker in the same centered, focused 70% × 60%
  floating pane. Esc cancels; opening a project closes the pane after creating
  or reusing its session and switching to it. No temporary tab is created.
- **Ctrl+A, Enter** toggles the last two sessions selected through the session
  picker or project picker (**Ctrl+A, F**).
- **Ctrl+A, L** remains right-pane navigation; it is not the session toggle.

Reload through Rex's **Reload Config** command, or run `rex config reload`, to
activate the consolidated Lua action registration. The compatible command wrappers
run Lua immediately on their next invocation; no automatic reload is performed.
Then switch from session A to B with either picker. Press **Ctrl+A, Enter**
twice: it should return to A, then B.

Requirements are `fzf`, a Rex version with the documented `rex.exec.start`/handle
Lua functions, and macOS built-ins including `lockf`, `find`, `sort`, `realpath`,
`openssl`, `mktemp`, and `dd` with `conv=fsync` support. Linux/Windows portability
is not implemented.

The launchers share `scripts/picker.sh`. Executable lookup checks PATH, Rex's
managed macOS installation, and local/Homebrew locations, since app-launched
actions may have a minimal PATH. It never sources shell startup files.
Session IDs are hidden: the list shows names and the last-used marker only.
Hidden IDs still identify selections safely when names are duplicated; use the
preview to tell identical names apart. fzf's default colors are left unchanged.
Session selection uses
Rex Remote Control, which must be enabled in the app (the project picker
already required it). Errors from the toggle are reported by the Rex action;
picker errors remain visible in their floating pane until Enter is pressed.

## Session snapshots

Highlighting a session starts a read-only snapshot worker for its focused terminal
in its active tab. The preview refreshes on highlight changes, not continuously;
it is text, not an image of the whole session layout. Missing sessions, missing
focus, non-terminal panes, and failed/slow requests show `Preview unavailable`
without preventing selection. If no other sessions exist, the picker reports
`No other sessions available` without changing history.

Snapshots are screen-aware: ordinary shells show recent output, while alternate-
screen apps such as Neovim are shown from the top instead of losing the upper
part of the screen. Use **Ctrl+U / Ctrl+D** to page the preview up/down; these keys
scroll fzf's snapshot only and never send input to the target terminal. The preview
is plain text, not a rescaled screenshot, so wide editor layouts may not fit.

Previews do not run before the list opens. A worker waits 75 ms for navigation to
settle, has a two-second work budget, and terminates pending Rex children when
cancelled. It retrieves a bounded 32 KiB tail for shell output, or a head with a
32 KiB encoded-byte budget for alternate screens, rather than downloading all
scrollback. Shell output is capped to 200 lines and the available preview rows;
alternate-screen output keeps up to 200 lines for scrolling and shows
`[Preview truncated]` if byte/line limits cut it short. Terminal control sequences
are stripped. No snapshots are cached on disk, and previewing never switches
sessions, sends input, or writes history.

Snapshot RPCs use attach-aware Rex CLI reads with bounded stdout/stderr capture;
native generic Lua RPC has no response-byte limit. Short-lived process groups and
an owner-liveness guard clean up descendants even when Rex exits before signaling
them. The guard checks every 50 ms while a bounded command runs; it is not a
persistent daemon. Cleanup can finish shortly after the preview's Rex CLI exits.

These limits bound client transfer and display, **not Rex's internal formatting
cost**: Rex may still format full scrollback before returning a bounded result.
Actual UI responsiveness and preview cancellation need manual confirmation in
the app; regression tests use fake terminal data and installed fzf.

## History and limits

The picker's first item uses the same remembered destination as the last-used
toggle. If that target is missing/closed, history is missing/unreadable/ambiguous,
or the optional host-status lookup fails, the list stays alphabetical. Opening
the picker only reads an atomic history snapshot without locking or rewriting it.
When nonempty history exists, ordering adds at most one host-status request with
a 500 ms timeout; no ordering-status request is made without history. Switch-time
validation is still strict: malformed history is never silently overwritten.

`lua/picker/sessions.lua` stores session IDs (not names) in
`$XDG_CONFIG_HOME/rex/state/session-history.json`, defaulting to
`~/.config/rex/state/session-history.json`. The code root can move without moving
that host-owned state. History is separated by host, written atomically
under a file lock, and ignored by Git. All apps connected to the same host share
one last-used pair, so restarting the app or changing its connection ID does not
reset history. The current client ID is used only to address the connected app.
Kernel locking uses the same lock file and automatically releases when the actual
transaction worker exits. If its coordinator dies while the worker is still
running, the lock remains held rather than admitting a concurrent writer.
Renaming a session is safe. Writes use a private same-directory temporary file,
file fsync, then atomic rename; malformed state is never silently repaired.

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
There is no persistent background process, and merely opening or cancelling either
picker does not record a switch. Case-insensitive Unicode ordering uses macOS's
locale-aware sort and can differ slightly from the old Node/ICU punctuation or
accent ordering; equal labels use hidden full IDs as deterministic ties.

## Project directories

**Ctrl+A, F** uses `lua/picker/projects.lua`; the existing
`~/.local/bin/rex-project-picker` command invokes the same Lua functionality.
It reads `$XDG_CONFIG_HOME/rex/projects.json`, defaulting to
`~/.config/rex/projects.json` (or pass `--config FILE` directly).
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
Session matching explicitly attaches the worker's temporary Lua inspection stream,
reads its layout/cwd metadata through native Lua, then detaches even if a read
fails. It never changes the app's selected session. Generic
`rex.call("session.view", ...)` without attachment would fail with a 409 conflict.
Canonical cwd results are cached only for that one scan, not across project opens.

To open a directory directly:

```sh
rex-project-picker ~/code/my-project
rex-project-picker --client CLIENT_ID -- ./-project-with-leading-dash
```

## Tests

From the dotfiles root, run:

```sh
node --test tests/*.test.mjs
rex --autostart=false config check .config/rex/init.lua
```

Node is a **development-only test runner**, not a production dependency. The suites
run real Lua modules/workers inside Rex, isolated fake API/client responses, temporary
project/state files, real kernel-lock contention, installed fzf, and private PTYs.
The no-Node CLI suite uses shell/Lua fakes and poisons Node startup (including an
absolute Node executable) to catch hidden runtime dependencies.

Embedded-Lua tests require an already-running Rex for its initial CLI connection;
autostart is disabled and fake adapters forbid live session/client operations.
An optional standalone `lua` is used by the offline config-action harness only.
Tests do not create, select, capture, or modify live sessions. Real-app appearance,
remote-control permissions, and live interaction still need manual confirmation.

`text-data.lua` is checked in. Its Unicode version is recorded in its header; the
offline generator is `tests/helpers/generate-rex-unicode.mjs`. It is not run at startup.
