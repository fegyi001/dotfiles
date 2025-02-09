# zmodload zsh/zprof

# If you come from bash you might have to change your $PATH.
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
export PATH=$HOME/bin:/usr/local/bin:$JAVA_HOME/bin:/$HOME/.local/bin:/$HOME/programs/flutter/bin:/$HOME/development/flutter/bin:$PATH:/$HOME/.cargo/bin:/$HOME/go/bin
export ANDROID_HOME=$HOME/Library/Android/sdk
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export BW_SESSION="rzVkMk0522cnJjRNBWKJ5j2OzQSxudfYkZfKB12SNjPCxVngkaiMDpojDos6K68mqLlpn3i7OLiiBx4bQGVtmw=="

export NVM_DIR="$HOME/.nvm"
# Load NVM only when running a Node.js-related command
load_nvm() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
# export NVM_DIR="$HOME/.nvm"
#   [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
#   [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Alias common Node commands to trigger lazy loading
nvm() { unset -f nvm; load_nvm; nvm "$@"; }
node() { unset -f node; load_nvm; node "$@"; }
npm() { unset -f npm; load_nvm; npm "$@"; }
yarn() { unset -f yarn; load_nvm; yarn "$@"; }

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

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
  vi-mode
  web-search
  docker
  colorize
  colored-man-pages
  tmux
  fzf
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
alias ls="eza"
alias ll="eza --long --header --git --icons --all --group-directories-first"
alias tree="ll --tree --level=4 -I=.git --git-ignore"
alias weather="curl http://wttr.in/budapest"
alias s="source ~/.zshrc"
alias c="clear"
alias n="nvim"
alias e="exit"
alias t="tmux"
alias to="tokei"
# alias vim="nvim"
alias cd="z" 
alias cat="bat"
alias v="fd --type f --hidden --exclude .git | fzf-tmux -p | xargs nvim"
alias prune="git branch | grep -v \"develop\" | xargs git branch -D"
alias gpd="git pull origin develop"
alias gpn="git pull origin next"
alias gp="git pull"
alias gP="git push --follow-tags"
alias grh="git reset --hard && git clean -fd"
alias gpc="git pull && git checkout "
alias y="yazi"
alias python="python3"
alias sed="gsed"
alias dc="docker compose"
alias dcb="docker compose build"
alias dcd="docker compose down"
alias dcu="docker compose up"
alias dcl="docker compose logs -f"
# Rust
alias cr="cargo run"
alias cw="cargo watch"

# brew install tealdeer
# https://www.youtube.com/watch?v=4EE7qlTaO7c
# alias tldrf='tldr --list | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
alias pip=pip3
source $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Use fd insstead of fzf
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd to generate the list for path completion
_fzf_compgen_path() {
  fd --hidden --follow --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude .git . "$1"
}

source ~/fzf-git.sh/fzf-git.sh

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

# if [ -z "$TMUX" ]
# then
#     tmux attach -t TMUX || tmux new -s TMUX
# fi

# Enable vi mode
bindkey -v

export BAT_THEME="Monokai Extended Origin"
export STARSHIP_CONFIG=~/.config/starship.toml
export PATH="${HOME}/.pyenv/shims:${PATH}"
eval "$(starship init zsh)"
export PNPM_HOME="$HOME/.pnpm"
export PATH="/opt/homebrew/opt/ruby/bin:$HOME/.pnpm:$PATH"
export SZENTPETERYFOTO_DATA_DIR="$HOME/data/SZENTPETERYFOTO_DATA"
export CERTS_DIR="$HOME/data/digitalocean/certs"

export DKFKFT_DATA_DIR="$HOME/data/dkfkft/DKFKFT_DATA"
export PREUR_DATA_DIR="$HOME/data/PREUR_DATA"
export SPRING_PROFILES_ACTIVE=local,debug
 
# thefuck alias
# eval $(thefuck --alias)
# eval $(thefuck --alias fk)

# zoxide (better cd)
eval "$(zoxide init zsh)"

# automatically move into the directory I'm in when exiting yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
# Set the editor to neovim for yazi
export EDITOR=nvim

# zprof
