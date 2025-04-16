# ZSH Configuration

# History Configuration
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# OS Detection
if [[ $(uname) == "Darwin" ]]; then
    export SYSTEM="MacOS"
elif [[ -f /proc/version ]] && grep -q "Microsoft" /proc/version; then
    export SYSTEM="WSL"
elif [[ -f /etc/arch-release ]]; then
    export SYSTEM="Arch"
else
    export SYSTEM="Linux"
fi

# SSH Agent Configuration
if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval $(ssh-agent -s) > /dev/null 2>&1
fi

# Enable Starship if installed
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Enable thefuck if installed
if command -v thefuck >/dev/null 2>&1; then
    eval $(thefuck --alias)
fi

# Universal aliases (work on all systems)
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias home='cd ~'
alias ports='sudo lsof -i -P -n | grep LISTEN'
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias grep='grep --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias df='df -h'
alias du='du -h'

# System-specific package management aliases
if [[ $SYSTEM == "Arch" ]]; then
    # Arch-specific aliases
    alias update='sudo pacman -Syu'
    alias clean='sudo pacman -Sc'
    alias remove='sudo pacman -R'
    alias search='pacman -Ss'
    alias install='sudo pacman -S'
    alias cleanpkg='sudo pacman -R $(pacman -Qdtq)'
elif [[ $SYSTEM == "MacOS" ]]; then
    # MacOS-specific aliases
    alias update='brew update && brew upgrade'
    alias clean='brew cleanup'
    alias remove='brew uninstall'
    alias search='brew search'
    alias install='brew install'
    # Enable colorized output for ls on MacOS
    alias ls='ls -G'
elif [[ $SYSTEM == "WSL" ]]; then
    # WSL-specific aliases (assuming Ubuntu/Debian based)
    alias update='sudo apt update && sudo apt upgrade'
    alias clean='sudo apt clean'
    alias remove='sudo apt remove'
    alias search='apt search'
    alias install='sudo apt install'
    alias cleanpkg='sudo apt autoremove'
fi

# Conditional aliases based on installed programs
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --style=full --theme=Nord'
fi

if command -v fastfetch >/dev/null 2>&1; then
    alias sysinfo='fastfetch'
elif command -v neofetch >/dev/null 2>&1; then
    alias sysinfo='neofetch'
fi

# Directory aliases (adjust these paths based on your setup)
if [[ $SYSTEM == "Arch" ]]; then
    alias hypr='cd ~/.config/hypr'
fi

# Universal config aliases (work across systems)
alias dots='cd ~/Documents/dotfiles'  # Assuming you keep dotfiles in the same place
alias config='cd ~/.config'
alias free='free -h'

# System-specific PATH and environment settings
if [[ $SYSTEM == "MacOS" ]]; then
    # MacOS specific settings
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)"
elif [[ $SYSTEM == "WSL" ]]; then
    # WSL specific settings
    # Add any WSL-specific PATH or env variables here
fi

# Basic auto/tab completion
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Useful aliases
alias nf='clear && neofetch run'
alias vim='nvim'

# Git aliases
alias g='git'
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gl='git log --oneline'
alias bup='brew update && brew upgrade'

# Directory shortcuts
alias dev='cd ~/Development'
alias docs='cd ~/Documents'
alias dl='cd ~/Downloads'

# Custom functions
# mkcd - Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# extract - Extract most know archives with one command
extract() {
    if [ -f $1 ] ; then
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
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# fh - Search command history
fh() {
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Environment variables
export EDITOR='nvim'
export VISUAL='nvim'
export PATH="$HOME/.local/bin:$PATH"

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Remove the basic prompt since we're using starship
# PROMPT='%F{cyan}%n%f@%F{magenta}%m%f:%F{yellow}%~%f ${vcs_info_msg_0_}%# '

