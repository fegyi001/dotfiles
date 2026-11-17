# Rex configuration

This directory owns keybindings, inline navigation settings, and host runtime
state. Reusable navigation code and its tests live in
`/Users/padanyig/code/github/rex-navigator`, linked here as `rex-navigator/`.
See [the plugin README](rex-navigator/README.md) for usage, architecture, limits,
dependencies, and test commands.

`init.lua` registers navigation actions and supplies project settings directly:

```lua
require("rex-navigator").setup({
  projects = {
    roots = {
      { path = "~/code", depth = 2 },
      { path = "~/dotfiles", depth = 1 },
      { path = "~/data", depth = 1 },
    },
    exclude = { "node_modules" },
  },
})
```

Edit the `setup()` table in `init.lua` to change project roots, traversal depths,
or excluded directory names. No `navigation-config.lua` or `projects.json` is
needed. Use the plugin through the keybindings in `lua/keys.lua`:

- Ctrl+A, Space: session picker.
- Ctrl+A, F: project picker.
- Ctrl+A, Enter: last-used session toggle.
- Ctrl+A, lowercase L: right-pane navigation, unchanged.

The separate `lua/navigation.lua` file integrates editor/terminal pane navigation;
it is unrelated to the extracted session/project plugin and remains host-owned.

Reload Rex's configuration once to activate the inline project settings. Actions
loaded before this change do not have those settings, and their project discovery
would look for the now-removed `navigation-config.lua`. No reload is automatic.
`scripts/picker.sh` preserves the old action entrypoint path, not its configuration.
`scripts/session-picker.sh` preserves the original session CLI path as a forwarder.

History stays under `$XDG_CONFIG_HOME/rex/state/`; project associations stay under
`$XDG_STATE_HOME/rex/project-sessions.json`, using the usual home-directory fallbacks.
Neither is moved into the plugin. Validate config without reloading:

```sh
rex --autostart=false config check ~/.config/rex/init.lua
```
