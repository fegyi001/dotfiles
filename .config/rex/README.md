# Rex configuration

This directory owns keybindings, editable navigation settings, and host runtime
state. Reusable navigation code and its tests live in
`/Users/padanyig/code/github/rex-navigation`, linked here as `rex-navigation/`.
See [the plugin README](rex-navigation/README.md) for usage, architecture, limits,
dependencies, and test commands.

`init.lua` registers navigation actions with:

```lua
require("rex-navigation.lua.navigation").setup()
```

Edit `navigation-config.lua` to change project roots, traversal depths, or excluded
directory names. Both the keyboard actions and `rex-project-picker` read it;
`projects.json` is no longer used. Keybindings remain in `lua/keys.lua`:

- Ctrl+A, Space: session picker.
- Ctrl+A, F: project picker.
- Ctrl+A, Enter: last-used session toggle.
- Ctrl+A, lowercase L: right-pane navigation, unchanged.

The separate `lua/navigation.lua` file integrates editor/terminal pane navigation;
it is unrelated to the extracted session/project plugin and remains host-owned.

The Stow-managed `~/.local/bin/rex-project-picker` forwards to the linked plugin.
`scripts/picker.sh` is a compatibility bridge for actions loaded before extraction,
so those actions continue to work until a manual reload. No reload is automatic.
`scripts/session-picker.sh` preserves the original session CLI path as a forwarder.

History stays under `$XDG_CONFIG_HOME/rex/state/`; project associations stay under
`$XDG_STATE_HOME/rex/project-sessions.json`, using the usual home-directory fallbacks.
Neither is moved into the plugin. Validate config without reloading:

```sh
rex --autostart=false config check ~/.config/rex/init.lua
```
