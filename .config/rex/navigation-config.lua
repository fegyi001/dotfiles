-- Shared navigation settings for Rex actions and rex-project-picker.
return {
  projects = {
    roots = {
      { path = "~/code", depth = 2 },
      { path = "~/dotfiles", depth = 1 },
      { path = "~/data", depth = 1 },
    },
    exclude = { "node_modules" },
  },
}
