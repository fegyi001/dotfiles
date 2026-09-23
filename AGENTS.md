# Agent Guidelines for Dotfiles Repository

## Build/Test Commands

This is a personal dotfiles repository with no build system. No tests or package.json exist.

## Code Style

- **Lua**: 2 spaces, 120 char width (.config/nvim/stylua.toml), LazyVim conventions
- **Shell**: Follow existing .zshrc style, use proper shebang headers
- **TOML/YAML**: 2-space indentation, follow existing config patterns

## File Organization

- Config files in `.config/` subdirectories by tool
- Install scripts in `install/` directory
- Symlink management with GNU Stow

## Editor Conventions

- Neovim: LazyVim distribution, 2-space tabs, relative line numbers
- Disable spell check and syntax highlighting globally

## Naming

- Kebab-case for config files, directories, and shell scripts (e.g., `install-npm-packages.sh`)
- Follow tool-specific naming conventions (e.g., `init.lua`)
