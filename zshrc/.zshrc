# ZSH Configuration

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

# History Configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Homebrew Configuration (macOS only)
if [[ $SYSTEM == "MacOS" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
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

# System-specific package management aliases
if [[ $SYSTEM == "Arch" ]]; then
    # Arch-specific aliases
    alias update='sudo pacman -Syu'
    alias clean='sudo pacman -Sc'
    alias remove='sudo pacman -R'
    alias search='pacman -Ss'
    alias install='sudo pacman -S'
    alias cleanpkg='sudo pacman -R $(pacman -Qdtq)'
    alias hypr='cd ~/.config/hypr'  # Only for Arch with Hyprland
elif [[ $SYSTEM == "MacOS" ]]; then
    # MacOS-specific aliases
    alias update='brew update && brew upgrade'
    alias clean='brew cleanup'
    alias remove='brew uninstall'
    alias search='brew search'
    alias install='brew install'
    # Enable colorized output for ls on MacOS
    alias ls='eza --color=auto'
elif [[ $SYSTEM == "WSL" ]]; then
    # WSL-specific aliases (assuming Ubuntu/Debian based)
    alias update='sudo apt update && sudo apt upgrade'
    alias clean='sudo apt clean'
    alias remove='sudo apt remove'
    alias search='apt search'
    alias install='sudo apt install'
    alias cleanpkg='sudo apt autoremove'
fi

# Useful aliases
alias nf='clear && neofetch run'
alias ll='eza -lah'
alias la='eza -A'
alias l='eza -CF'
alias ..='cd ..'
alias ...='cd ../..'
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
# bup alias is defined in macOS-specific section above

# Directory shortcuts
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

# Initialize starship prompt
eval "$(starship init zsh)"

# Remove the basic prompt since we're using starship
# PROMPT='%F{cyan}%n%f@%F{magenta}%m%f:%F{yellow}%~%f ${vcs_info_msg_0_}%# '

# FZF configuration
if [[ -d "/opt/homebrew/opt/fzf" ]]; then
  # Source FZF keybindings and completion (Homebrew install)
  [[ -f "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" ]] && source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
  [[ -f "/opt/homebrew/opt/fzf/shell/completion.zsh" ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh"
fi

# FZF default options (customize as desired)
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview "bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null"
  --preview-window=right:60%
'

# TheFuck
eval $(thefuck --alias)
