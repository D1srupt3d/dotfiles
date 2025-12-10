# ============================================================================
# ZSH Configuration
# ============================================================================

# ----------------------------------------------------------------------------
# OS Detection
# ----------------------------------------------------------------------------
detect_os() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "MacOS"
    elif [[ -f /proc/sys/kernel/osrelease ]] && grep -qi "microsoft" /proc/sys/kernel/osrelease; then
        echo "WSL"
    elif [[ -f /etc/arch-release ]]; then
        echo "Arch"
    elif [[ -f /etc/debian_version ]]; then
        echo "Debian"
    elif [[ -f /etc/fedora-release ]]; then
        echo "Fedora"
    else
        echo "Linux"
    fi
}

export SYSTEM="$(detect_os)"

# ----------------------------------------------------------------------------
# History Configuration
# ----------------------------------------------------------------------------
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY           # Append instead of overwrite
setopt EXTENDED_HISTORY         # Add timestamps to history
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicates first
setopt HIST_IGNORE_DUPS         # Don't record duplicates
setopt HIST_IGNORE_SPACE        # Ignore commands starting with space
setopt HIST_VERIFY              # Show command with history expansion before running
setopt HIST_REDUCE_BLANKS       # Remove unnecessary blanks
setopt INC_APPEND_HISTORY       # Add commands immediately
# Note: SHARE_HISTORY disabled to prevent race conditions in concurrent shells

# ----------------------------------------------------------------------------
# Homebrew Configuration (macOS only)
# ----------------------------------------------------------------------------
if [[ "$SYSTEM" == "MacOS" ]] && [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# ----------------------------------------------------------------------------
# Completion System
# ----------------------------------------------------------------------------
autoload -Uz compinit

# Speed up compinit by only checking once a day
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # Colored completion
zstyle ':completion:*' rehash true                         # Rehash for new commands
zstyle ':completion:*' accept-exact '*(N)'                 # Speed up
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${HOME}/.zcompcache"

zmodload zsh/complist
_comp_options+=(globdots) # Include hidden files

# ----------------------------------------------------------------------------
# Vi Mode Configuration
# ----------------------------------------------------------------------------
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect '^[[Z' reverse-menu-complete # Shift-Tab

# Better vi mode bindings
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

# ----------------------------------------------------------------------------
# System-Specific Package Management Aliases
# ----------------------------------------------------------------------------
case "$SYSTEM" in
    Arch)
        alias update='sudo pacman -Syu'
        alias clean='sudo pacman -Sc'
        alias remove='sudo pacman -R'
        alias search='pacman -Ss'
        alias install='sudo pacman -S'
        alias cleanpkg='sudo pacman -Rns $(pacman -Qdtq 2>/dev/null)'
        [[ -d "${HOME}/.config/hypr" ]] && alias hypr='cd ~/.config/hypr'
        ;;
    MacOS)
        alias update='brew update && brew upgrade'
        alias clean='brew cleanup'
        alias remove='brew uninstall'
        alias search='brew search'
        alias install='brew install'
        ;;
    Debian|WSL)
        alias update='sudo apt update && sudo apt upgrade -y'
        alias clean='sudo apt clean && sudo apt autoclean'
        alias remove='sudo apt remove'
        alias search='apt search'
        alias install='sudo apt install'
        alias cleanpkg='sudo apt autoremove -y'
        ;;
    Fedora)
        alias update='sudo dnf update -y'
        alias clean='sudo dnf clean all'
        alias remove='sudo dnf remove'
        alias search='dnf search'
        alias install='sudo dnf install'
        alias cleanpkg='sudo dnf autoremove -y'
        ;;
esac

# ----------------------------------------------------------------------------
# Modern Replacements for Traditional Commands
# ----------------------------------------------------------------------------
# Use eza if available, otherwise fallback to ls
if command -v eza &>/dev/null; then
    alias ls='eza --color=auto --group-directories-first'
    alias ll='eza -lah --git'
    alias la='eza -A'
    alias l='eza -CF'
    alias lt='eza --tree --level=2'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah'
    alias la='ls -A'
    alias l='ls -CF'
fi

# Use bat if available for better cat
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain --paging=never'
    alias ccat='/bin/cat' # Original cat
fi

# ----------------------------------------------------------------------------
# General Aliases
# ----------------------------------------------------------------------------
alias nf='clear && neofetch'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Disk usage
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Process management
alias ps='ps auxf'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

# Network
alias myip='curl -s ifconfig.me'
alias ports='netstat -tulanp'

# ----------------------------------------------------------------------------
# Git Aliases
# ----------------------------------------------------------------------------
alias g='git'
alias gst='git status'
alias gss='git status -s'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline'
alias glg='git log --graph --oneline --decorate --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gm='git merge'
alias gr='git remote'
alias grv='git remote -v'
alias gf='git fetch'

# ----------------------------------------------------------------------------
# Directory Shortcuts
# ----------------------------------------------------------------------------
alias docs='cd ~/Documents'
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias dev='cd ~/Developer 2>/dev/null || cd ~/Development 2>/dev/null || cd ~/dev 2>/dev/null'

# ----------------------------------------------------------------------------
# Custom Functions
# ----------------------------------------------------------------------------

# mkcd - Create directory and cd into it
mkcd() {
    if [[ -z "$1" ]]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi
    mkdir -p "$1" && cd "$1" || return 1
}

# backup - Create a backup of a file
backup() {
    if [[ -z "$1" ]]; then
        echo "Usage: backup <file>"
        return 1
    fi
    if [[ ! -f "$1" ]]; then
        echo "Error: '$1' is not a file"
        return 1
    fi
    cp "$1" "${1}.backup.$(date +%Y%m%d-%H%M%S)"
}

# extract - Extract most known archives with one command
extract() {
    if [[ -z "$1" ]]; then
        echo "Usage: extract <archive>"
        return 1
    fi
    
    if [[ ! -f "$1" ]]; then
        echo "Error: '$1' is not a valid file"
        return 1
    fi
    
    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.xz)         tar xJf "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *.rar)            unrar x "$1" ;;
        *.gz)             gunzip "$1" ;;
        *.tar)            tar xf "$1" ;;
        *.zip)            unzip "$1" ;;
        *.Z)              uncompress "$1" ;;
        *.7z)             7z x "$1" ;;
        *)                echo "Error: '$1' cannot be extracted via extract()" ;;
    esac
}

# fh - Search command history with fzf
fh() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is not installed"
        return 1
    fi
    
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | \
        fzf +s --tac --height=50% --border | \
        sed -E 's/ *[0-9]*\*? *//' | \
        sed -E 's/\\/\\\\/g')
}

# fd - cd to selected directory using fzf
fd() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is not installed"
        return 1
    fi
    
    local dir
    dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2>/dev/null | fzf +m) && cd "$dir"
}

# fkill - Kill process using fzf
fkill() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is not installed"
        return 1
    fi
    
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    
    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -${1:-9}
    fi
}

# mkv - Create and activate Python virtual environment
mkv() {
    local venv_name="${1:-.venv}"
    python3 -m venv "$venv_name" && source "$venv_name/bin/activate"
}

# weather - Get weather forecast
weather() {
    local location="${1:-}"
    curl -s "wttr.in/${location}?format=3"
}

# cheat - Quick cheatsheet lookup
cheat() {
    if [[ -z "$1" ]]; then
        echo "Usage: cheat <command>"
        return 1
    fi
    curl -s "cheat.sh/$1"
}

# ----------------------------------------------------------------------------
# Color Man Pages
# ----------------------------------------------------------------------------
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin bold
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin blink
export LESS_TERMCAP_me=$'\E[0m'           # reset bold/blink
export LESS_TERMCAP_se=$'\E[0m'           # reset reverse video
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin reverse video
export LESS_TERMCAP_ue=$'\E[0m'           # reset underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

# ----------------------------------------------------------------------------
# Environment Variables
# ----------------------------------------------------------------------------
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LESS='-R -i -M -W'

# Add local bin to PATH if not already present
[[ ":$PATH:" != *":${HOME}/.local/bin:"* ]] && export PATH="${HOME}/.local/bin:${PATH}"

# Set up colors for ls
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# ----------------------------------------------------------------------------
# Node Version Manager (Lazy Load for Performance)
# ----------------------------------------------------------------------------
export NVM_DIR="${HOME}/.nvm"

# Lazy load NVM to improve shell startup time
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # Create placeholder functions
    nvm() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        nvm "$@"
    }
    
    node() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        node "$@"
    }
    
    npm() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        npm "$@"
    }
    
    npx() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        npx "$@"
    }
fi

# ----------------------------------------------------------------------------
# FZF Configuration
# ----------------------------------------------------------------------------
if command -v fzf &>/dev/null; then
    # Source FZF keybindings and completion
    if [[ "$SYSTEM" == "MacOS" ]] && [[ -d "/opt/homebrew/opt/fzf" ]]; then
        [[ -f "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" ]] && source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
        [[ -f "/opt/homebrew/opt/fzf/shell/completion.zsh" ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh"
    else
        [[ -f "/usr/share/fzf/key-bindings.zsh" ]] && source "/usr/share/fzf/key-bindings.zsh"
        [[ -f "/usr/share/fzf/completion.zsh" ]] && source "/usr/share/fzf/completion.zsh"
        [[ -f "${HOME}/.fzf.zsh" ]] && source "${HOME}/.fzf.zsh"
    fi
    
    # FZF default options
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null || find . -type f'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git 2>/dev/null || find . -type d'
    
    export FZF_DEFAULT_OPTS='
        --height=60%
        --layout=reverse
        --border
        --info=inline
        --prompt="❯ "
        --pointer="▶"
        --marker="✓"
        --bind=ctrl-u:preview-half-page-up
        --bind=ctrl-d:preview-half-page-down
        --bind=ctrl-f:preview-page-down
        --bind=ctrl-b:preview-page-up
        --color=fg:#d0d0d0,bg:#121212,hl:#5f87af
        --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
        --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff
        --color=marker:#87ff00,spinner:#af5fff,header:#87afaf
    '
    
    # Preview with bat or cat
    if command -v bat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
    else
        export FZF_CTRL_T_OPTS="--preview 'cat {}'"
    fi
    
    export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} 2>/dev/null || tree -C {} | head -200'"
fi

# ----------------------------------------------------------------------------
# Zoxide (Smarter cd command)
# ----------------------------------------------------------------------------
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# ----------------------------------------------------------------------------
# TheFuck (Lazy Load)
# ----------------------------------------------------------------------------
if command -v thefuck &>/dev/null; then
    # Lazy load thefuck
    fuck() {
        unset -f fuck
        eval "$(thefuck --alias)"
        fuck "$@"
    }
fi

# ----------------------------------------------------------------------------
# Starship Prompt
# ----------------------------------------------------------------------------
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
else
    # Fallback prompt if starship is not installed
    autoload -Uz vcs_info
    precmd() { vcs_info }
    zstyle ':vcs_info:git:*' formats ' (%b)'
    setopt PROMPT_SUBST
    PROMPT='%F{cyan}%n%f@%F{magenta}%m%f:%F{yellow}%~%f${vcs_info_msg_0_} %# '
fi

# ----------------------------------------------------------------------------
# ZSH Plugins (Optional - uncomment if you have them installed)
# ----------------------------------------------------------------------------

# Syntax highlighting (install: git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting)
# [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# [[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestions (install: git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions)
# [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# [[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# ----------------------------------------------------------------------------
# Local Configuration
# ----------------------------------------------------------------------------
# Source local configuration file if it exists (for machine-specific settings)
[[ -f "${HOME}/.zshrc.local" ]] && source "${HOME}/.zshrc.local"

# ----------------------------------------------------------------------------
# Welcome Message (Optional)
# ----------------------------------------------------------------------------
# Uncomment to see system info on shell startup
# [[ -o interactive ]] && command -v neofetch &>/dev/null && neofetch

# Performance profiling (uncomment to measure shell startup time)
# zprof
