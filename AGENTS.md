# Agent Guidelines for Dotfiles Repository

## Build/Lint/Test Commands

This is a dotfiles configuration repository. No traditional build process exists.

**Linting:**
- Lua: `stylua --check .` (format check) or `stylua .` (format)
- Markdown: `markdownlint-cli2 "**/*.md"` (lint markdown files)

**No test framework configured** - this is a configuration repository.

## Code Style Guidelines

### Lua (Neovim Configuration)
- **Indentation**: 2 spaces (configured in `.config/nvim/stylua.toml`)
- **Line width**: 120 characters maximum
- **Naming**: Follow Neovim/Lua conventions (snake_case for variables, PascalCase for modules)
- **Imports**: Use `require()` for modules, avoid global variables
- **Error handling**: Use `vim.notify()` for user-facing errors, `error()` for programming errors
- **Types**: No explicit type annotations (dynamic typing)
- **Comments**: Minimal comments, prefer self-documenting code

### Configuration Files
- **Shell scripts**: Use `#!/bin/bash`, follow POSIX shell standards
- **TOML/JSON**: 2-space indentation, trailing commas where appropriate
- **Naming**: kebab-case for file names, consistent with tool conventions

### General
- **Framework**: LazyVim-based Neovim configuration
- **Plugins**: Use lazy.nvim for plugin management
- **Security**: Never commit secrets or sensitive configuration
- **Documentation**: Keep README.md minimal and focused

No Cursor rules or Copilot instructions found in repository.