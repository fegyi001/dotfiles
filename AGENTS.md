# Agent Guidelines for Dotfiles Repository

## Build/Test Commands
This is a personal dotfiles repository with no build system. No tests or package.json exist.

## Code Style
- **Lua**: 2 spaces, 120 char width (stylua.toml), LazyVim conventions
- **Shell**: Follow existing .zshrc style, use proper shebang headers 
- **TOML/YAML**: 2-space indentation, follow existing config patterns
- **TypeScript**: Prettier formatting, auto-format enabled in Helix

## File Organization  
- Config files in `.config/` subdirectories by tool
- Install scripts in `install/` directory
- Symlink management with GNU Stow

## Editor Conventions
- Neovim: LazyVim distribution, 2-space tabs, relative line numbers
- Helix: Auto-format on save, TypeScript/HTML with Prettier
- Disable spell check and syntax highlighting globally

## Naming
- Kebab-case for config files and directories
- Snake_case for shell scripts and executables
- Follow tool-specific naming conventions (e.g., `wezterm.lua`, `init.lua`)

## No Build/Test Commands
This repository contains personal configuration files only - no compilation, testing, or linting commands exist.