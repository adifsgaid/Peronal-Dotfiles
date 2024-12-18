# Enable instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Ruby
eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
# Theme configuration
ZSH_THEME="robbyrussell"

# Path configurations (early path setup)
export PATH=$HOME/bin:/usr/local/bin:/opt/homebrew/bin:$PATH

# Update behavior
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

# History configuration
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Suppress "You have new mail" message
unset MAILCHECK

# Enhanced plugins list (optimized)
plugins=(
    git
    node
    npm
    docker
    docker-compose
    vscode
    zsh-autosuggestions
    zsh-syntax-highlighting
    web-search
    copypath
    copyfile
    dirhistory
    history
    jsontools
    colored-man-pages
    command-not-found
    zsh-completions
)

# Add these lines after plugins declaration but before sourcing oh-my-zsh
autoload -Uz compinit
compinit

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Load aliases from separate file
[ -f ~/.aliases ] && source ~/.aliases

# Editor configuration
export EDITOR='cursor'
export VISUAL='cursor'

# Load secrets file
[ -f ~/.secrets ] && source ~/.secrets

# Node.js environment with NVM lazy loading
export NVM_DIR="$HOME/.nvm"
# Lazy load nvm for faster shell startup
nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm "$@"
}

# Python environment with lazy loading
export PATH="$HOME/.pyenv/bin:$PATH"
pyenv() {
    unset -f pyenv
    eval "$(command pyenv init -)"
    eval "$(command pyenv virtualenv-init -)"
    pyenv "$@"
}

# Additional PATH configurations
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$PATH:/Applications/Cursor.app/Contents/Resources/app/bin"

# Auto suggestions configuration
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^H' backward-delete-char

# Functions
mkcd() { mkdir -p "$@" && cd "$@"; }
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)          echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Set terminal colors
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Load local customizations if they exist
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# fzf configurations
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border
  --preview 'bat --style=numbers --color=always --line-range :500 {}'
"

# fzf key bindings and completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Custom fzf functions
# Search and edit file
fe() {
  local file
  file=$(fzf --query="$1" --select-1 --exit-0)
  [ -n "$file" ] && ${EDITOR:-cursor} "$file"
}

# Search git branches
fbr() {
  local branches branch
  branches=$(git branch -a) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Search git commits
fco() {
  local commits commit
  commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}

# Search command history
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

# Enhanced folder search with automatic home directory scanning
function fd() {
    local dir
    dir=$(find $HOME/* -maxdepth 3 \
        -path '*/\.*' -prune \
        -o -type d -print 2> /dev/null | \
        fzf +m \
            --preview 'tree -C {} | head -200' \
            --preview-window=right:50% \
            --bind='ctrl-d:preview-page-down' \
            --bind='ctrl-u:preview-page-up' \
            --height=80% \
            --layout=reverse \
            --border \
            --prompt="🔍 ")
    [ -n "$dir" ] && cd "$dir"
}
