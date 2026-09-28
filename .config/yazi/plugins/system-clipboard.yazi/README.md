# system-clipboard.yazi

Synchronize files between the Yazi file manager and your system clipboard. Supports both copy and paste on Linux, macOS, and Windows desktops.

## Features

- **Copy**: Yank files in Yazi and make them available to other applications via the system clipboard.
- **Paste**: Copy files from the system clipboard into the current Yazi directory, with conflict resolution (overwrite / rename / skip).

## Requirements

| Platform | Copy | Paste |
| -------- | ---- | ----- |
| Linux (X11) | `xclip` | `xclip` |
| Linux (Wayland) | `wl-copy` (`wl-clipboard`) | `wl-paste` (`wl-clipboard`) |
| macOS | Built-in `osascript` | Built-in `osascript` |
| Windows | Built-in `powershell.exe` | Built-in `powershell.exe` |

## Installation

This copy is stored as `plugins/system-clipboard.yazi` to avoid a name collision with Yazi's built-in `clipboard` plugin. To install the upstream plugin under its original name:

```bash
ya pkg add XYenon/clipboard
```

The package manager installs it as `plugins/clipboard.yazi`; rename that directory to `plugins/system-clipboard.yazi` and remove the `XYenon/clipboard` entry from `package.toml` to keep the renamed copy local.

## Usage

Add shortcuts in `~/.config/yazi/keymap.toml`:

```toml
# Copy yanked files to the system clipboard
[[mgr.prepend_keymap]]
on  = "y"
run = [ "yank", 'plugin system-clipboard -- --action=copy' ]
desc = "Yank selected files (copy)"

# Keep behaviour consistent with cut
[[mgr.prepend_keymap]]
on  = "x"
run = [ "yank --cut", 'plugin system-clipboard -- --action=copy' ]
desc = "Yank selected files (cut)"

# Paste files from the system clipboard into the current directory
[[mgr.prepend_keymap]]
on  = "<C-p>"
run = [ 'plugin system-clipboard -- --action=paste' ]
desc = "Paste yanked system clipboard files"
```

## Optional arguments

The plugin accepts the boolean argument `notify-unknown-display-server`:

- Default `false`: silently exit when the Linux display server is unknown (useful for TTY or remote sessions).
- `true`: show a notification to warn that the operation is unavailable in the current session.

Example invocation:

```toml
[[mgr.prepend_keymap]]
on  = "y"
run = [ "yank", 'plugin system-clipboard -- --action=copy --notify-unknown-display-server' ]
```

## Troubleshooting

- **`Copy failed: xclip/wl-copy not found`**: install `xclip` for X11 or `wl-clipboard` (`wl-copy`) for Wayland.
- **`Paste failed: xclip/wl-paste not found`**: install `xclip` for X11 or `wl-clipboard` (`wl-paste`) for Wayland.
- **`Unknown display server`**: ensure Yazi runs in a Wayland or X11 session. Enable `notify-unknown-display-server` to surface a visible warning.
- **`powershell.exe not found`**: ensure `%SystemRoot%\System32\WindowsPowerShell\v1.0` is on your `PATH`.

## Development

This repository uses [treefmt](https://github.com/numtide/treefmt) for formatting:

```bash
nix fmt
```

Feel free to open a PR to support more desktop environments.
