# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/d1srupt3d/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# SSD Agent
# Check if SSH agent is already running
if [ ! -S ~/.ssh/ssh-agent.sock ]; then
    # Start SSH agent and save the environment variables
    eval "$(ssh-agent -s)" > /dev/null
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh-agent.sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh-agent.sock

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
alias sysinfo='fastfetch'
alias hypr='cd ~/.config/hypr'
alias dots='cd ~/Documents/hypr-dots'
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

