# zmodload zsh/zprof

export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
export PATH=$HOME/bin:/usr/local/bin:$JAVA_HOME/bin:/$HOME/.local/bin:/$HOME/programs/flutter/bin:/$HOME/development/flutter/bin:$PATH:/$HOME/.cargo/bin:/$HOME/go/bin
export ANDROID_HOME=$HOME/Library/Android/sdk

export BW_SESSION="rzVkMk0522cnJjRNBWKJ5j2OzQSxudfYkZfKB12SNjPCxVngkaiMDpojDos6K68mqLlpn3i7OLiiBx4bQGVtmw=="

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

HYPHEN_INSENSITIVE="true"

plugins=(
  git 
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

alias zshconfig="nvim ~/.zshrc"
alias tn="tmux -u -f new"
alias ta="tmux -u -f attach"
alias lg="lazygit"
alias ldo="lazydocker"
alias cbr='git branch --sort=-committerdate | fzf --header "Checkout Recent Branch" --preview "git diff {1} --color=always" --pointer="" | xargs git checkout'
alias ls="eza"
alias ll="eza --long --header --git --icons --all --group-directories-first"
alias tree="ll --tree --level=4 -I=.git --git-ignore"
alias weather="curl http://wttr.in/budapest"
alias s="source ~/.zshrc"
alias c="clear"
alias n="nvim"
alias e="exit"
alias t="tmux a"
alias to="tokei"
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
alias ga="git add"
alias gc="git commit"
alias gcl="git clone"
alias gs="git status --short"
alias gd="git diff --output-indicator-new=' ' --output-indicator-old=' '"
alias gl="git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an %ar%C(auto) %D%n%s%n'"
alias y="yazi"
alias yi="yarn install"
alias ys="yarn s"
alias yt="yarn t"
alias python="python3"
alias sed="gsed"
alias dc="docker compose"
alias dcb="docker compose build"
alias dcd="docker compose down"
alias dcu="docker compose up"
alias dcl="docker compose logs -f"
alias cr="cargo run"
alias cw="cargo watch"
alias u="brew update && brew upgrade && brew cleanup"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
alias pip=pip3

# Use fd instead of fzf
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
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

# Enable vi mode
bindkey -v

export BAT_THEME="tokyonight_night"
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
 
# zoxide (better cd)
eval "$(zoxide init zsh)"

# fnm (node version manager)
eval "$(fnm env --use-on-cd --shell zsh)"

# Activate syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Disable underline
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# Activate autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

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
