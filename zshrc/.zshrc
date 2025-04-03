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

