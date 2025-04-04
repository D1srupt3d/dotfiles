#!/bin/bash

# Safety check - are we in a TTY or X session?
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    echo "ERROR: This script should not be run from TTY1 or without a display server!"
    echo "Please run this from a terminal within your Hyprland session."
    exit 1
fi

# Create backup directory with timestamp
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# First, backup everything
echo "Creating backup of all configs..."
for dir in btop dunst fastfetch ghostty hypr waybar wofi wlogout; do
    if [ -d "$HOME/.config/$dir" ]; then
        echo "Backing up $dir..."
        cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done

if [ -f "$HOME/.config/starship.toml" ]; then
    cp "$HOME/.config/starship.toml" "$BACKUP_DIR/"
fi

if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$BACKUP_DIR/"
fi

# Stow non-critical packages first
echo "Stowing non-critical packages..."
stow -v -t ~ btop fastfetch ghostty starship wlogout zshrc

# Stow packages that might affect the current session
echo "Stowing session-related packages..."
stow -v -t ~ dunst waybar wofi

# Finally, stow Hyprland configs
echo "Stowing Hyprland configs..."
stow -v -t ~ hypr

echo "Backup created in: $BACKUP_DIR"
echo "If you need to restore your old configs, they are in the backup directory."
echo "You may need to restart Hyprland for all changes to take effect." 