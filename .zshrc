# If you come from bash you might have to change your $PATH.
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
export PATH=$HOME/bin:/usr/local/bin:$JAVA_HOME/bin:/$HOME/.local/bin:/$HOME/programs/flutter/bin:/$HOME/install/nvim/bin:/$HOME/.local/share/bob/nvim-bin:$PATH
export ANDROID_HOME=$HOME/Library/Android/sdk
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
  #
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export BW_SESSION="rzVkMk0522cnJjRNBWKJ5j2OzQSxudfYkZfKB12SNjPCxVngkaiMDpojDos6K68mqLlpn3i7OLiiBx4bQGVtmw=="

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 2

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

plugins=(
  git 
  # npm
  # z
  # node
  # brew
  zsh-autosuggestions 
  zsh-syntax-highlighting 
  fast-syntax-highlighting
  # vi-mode
  web-search
  docker
  colorize
  colored-man-pages
  tmux
)

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias tn="tmux -u -f new"
alias ta="tmux -u -f attach"
alias tt="nvim ~/.tmux.conf"
alias lg="lazygit"
alias cbr='git branch --sort=-committerdate | fzf --header "Checkout Recent Branch" --preview "git diff {1} --color=always" --pointer="" | xargs git checkout'
alias ls="exa"
alias ll="exa --long --header --git --icons --all --group-directories-first" 
alias tree="ll --tree --level=4 -I=.git --git-ignore"
alias weather="curl http://wttr.in/budapest"
alias n="nvim"
alias vim="nvim"
alias v="fd --type f --hidden --exclude .git | fzf-tmux -p | xargs nvim"
alias prune="git branch | grep -v \"develop\" | xargs git branch -D"
alias gpd="git pull origin develop"
alias gp="git pull"
alias gP="git push"
alias grh="git reset --hard"
alias gpc="git pull && git checkout "

# brew install tealdeer
# https://www.youtube.com/watch?v=4EE7qlTaO7c
# alias tldrf='tldr --list | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
alias pip=pip3
source $HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# if [ -z "$TMUX" ]
# then
#     tmux attach -t TMUX || tmux new -s TMUX
# fi

# Enable vi mode
bindkey -v

export PATH="${HOME}/.pyenv/shims:${PATH}"
eval "$(starship init zsh)"

