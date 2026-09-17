#!/bin/bash

# git clone https://github.com/fegyi001/dotfiles.git ~/dotfiles
sudo pacman -S stow keyd zsh yazi fnm which firefox tokei rust
cd ~/dotfiles || exit 1
sudo rm -rf /etc/keyd
sudo ln -s ~/dotfiles/.config/keyd /etc
sudo systemctl enable keyd
sudo systemctl restart keyd
cd ~/dotfiles/install/omarchy || exit 1
./install-hungarian-keyboard.sh
cd ~/.config || exit 1
rm -rf bat/ tmux/ nvim/ lazygit/ hypr/ herdr/ git/ waybar/ opencode/ startship.toml
cd ~/dotfiles || exit 1
stow .
hyprctl reload
chsh -s "$(which zsh)"
cd ~/dotfiles/install || exit 1
./install-npm-packages.sh
./install-herdr-plugins.sh
mkdir -p ~/code
cd ~/dotfiles || exit 1
nvim
