# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Enable Starship
eval "$(starship init zsh)"

# Enable Fuck
eval $(thefuck --alias)

# Aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias update='sudo pacman -Syu'
alias clean='sudo pacman -Sc'
alias remove='sudo pacman -R'
alias search='pacman -Ss'
alias install='sudo pacman -S'
alias cleanpkg='sudo pacman -R $(pacman -Qdtq)'
alias sysinfo='fastfetch'
# Replace these paths with your actual configuration paths
alias hypr='cd ~/.config/hypr'
alias dots='cd ~/Documents/dotfiles'
alias config='code ~/.config'
alias home='cd ~'
alias root='sudo su'
alias ports='sudo lsof -i -P -n | grep LISTEN'
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias grep='grep --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias df='df -h'
alias free='free -h'
alias du='du -h'
alias mkdir='mkdir -pv'
alias cat='bat --style=full --theme=Nord'

