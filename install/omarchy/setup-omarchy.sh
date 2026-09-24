#!/bin/bash

# git clone https://github.com/fegyi001/dotfiles.git ~/dotfiles && \
# chmod +x ~/dotfiles/install/setup-omarchy.sh && \
# chmod +x ~/dotfiles/install/install-hungarian-keyboard.sh && \
# chmod +x ~/dotfiles/install/install-npm-packages.sh && \
# chmod +x ~/dotfiles/install/install-herdr-plugins.sh

echo "Installing packages"
sudo pacman -S stow keyd zsh yazi firefox fnm which tokei rust lazygit || exit 1
cd ~/dotfiles || exit 1

echo "Setting up keyd"
sudo rm -rf /etc/keyd
sudo ln -s ~/dotfiles/.config/keyd /etc
sudo systemctl enable keyd
sudo systemctl restart keyd

echo "Setting up hungarian keyboard"
cd ~/dotfiles/install/omarchy || exit 1
./install-hungarian-keyboard.sh

echo "Setting up dotfiles with stow"
cd ~/.config || exit 1
rm -rf bat/ btop/ tmux/ nvim/ lazygit/ hypr/ herdr/ git/ waybar/ opencode/ starship.toml
cd ~/dotfiles || exit 1
stow .
hyprctl reload

echo "Setting up zsh as default shell"
sudo chsh -s "$(which zsh)"

echo "Installing npm packages"
cd ~/dotfiles/install || exit 1
./install-npm-packages.sh

echo "Installing herdr"
curl -fsSL https://herdr.dev/install.sh | sh
echo "Installing herdr plugins"
./install-herdr-plugins.sh

cd ~/dotfiles || exit 1

echo "Opening neovim"
nvim
