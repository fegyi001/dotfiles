```ascii
████████▄   ▄██████▄      ███        ▄████████  ▄█   ▄█          ▄████████    ▄████████
███   ▀███ ███    ███ ▀█████████▄   ███    ███ ███  ███         ███    ███   ███    ███
███    ███ ███    ███    ▀███▀▀██   ███    █▀  ███▌ ███         ███    █▀    ███    █▀
███    ███ ███    ███     ███   ▀  ▄███▄▄▄     ███▌ ███        ▄███▄▄▄       ███
███    ███ ███    ███     ███     ▀▀███▀▀▀     ███▌ ███       ▀▀███▀▀▀     ▀███████████
███    ███ ███    ███     ███       ███        ███  ███         ███    █▄           ███
███   ▄███ ███    ███     ███       ███        ███  ███▌    ▄   ███    ███    ▄█    ███
████████▀   ▀██████▀     ▄████▀     ███        █▀   █████▄▄██   ██████████  ▄████████▀
```

Personal configuration for my daily setup across macOS and Linux ([Hyprland/Omarchy](https://omarchy.org/)). Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's inside

| Category         | Tools                                         |
| ---------------- | --------------------------------------------- |
| Shell & terminal | `zsh`, `starship`, `tmux`, `ghostty`, `herdr` |
| Editors          | `nvim` (LazyVim)                              |
| Git tooling      | `git`, `lazygit`                              |
| Window manager   | `hypr` (Hyprland), `waybar`                   |
| Input remapping  | `karabiner`, `keyd`                           |
| CLI utilities    | `bat`, `btop`, `yazi`                         |
| AI / agents      | `opencode`                                    |

## Install

Clone the repo, then use Stow to symlink whichever packages you want into `$HOME`:

```sh
git clone https://github.com/fegyi001/dotfiles ~/dotfiles
cd ~/dotfiles
stow .
```

### macOS package bootstrap

Homebrew formulas and casks are tracked in `install/mac/formulas.txt` and `install/mac/casks.txt`:

```sh
install/mac/install-formulas.sh   # install tracked formulas
install/mac/install-casks.sh      # install tracked casks (GUI apps)
install/mac/backup-brew.sh        # regenerate the tracked lists from current brew state
```

### Omarchy (Arch/Hyprland) bootstrap

`install/omarchy/setup-omarchy.sh` bootstraps a fresh Omarchy install: installs required packages, symlinks `keyd`, sets up keyboard layout, stows the dotfiles, switches the default shell to `zsh`, and installs `herdr` with its plugins.

```sh
git clone https://github.com/fegyi001/dotfiles.git ~/dotfiles
~/dotfiles/install/omarchy/setup-omarchy.sh
```

## Notes

These are personal configs tuned for my own workflow — feel free to borrow anything useful, but expect some assumptions specific to my machines (paths, hardware, app choices).

![Desktop screenshot](images/desktop_omarchy.png)
