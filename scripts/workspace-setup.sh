#!/bin/bash
# Workspace setup script - opens your standard layout
# Customize this based on your workflow

echo "Setting up workspaces..."

# Workspace 1 - Terminal
hyprctl dispatch workspace 1
ghostty &
sleep 1

# Workspace 2 - Browser
hyprctl dispatch workspace 2
firefox &
sleep 2

# Workspace 3 - Editor
hyprctl dispatch workspace 3
cursor &
sleep 2

# Workspace 4 - Music
# hyprctl dispatch workspace 4
# spotify &

# Return to workspace 1
hyprctl dispatch workspace 1

notify-send "Workspace Setup" "Standard layout loaded"
