#!/bin/bash

# First, create all the necessary directories
mkdir -p ~/hypr-dot/dunst/.config/dunst
mkdir -p ~/hypr-dot/hypr/.config/hypr
mkdir -p ~/hypr-dot/hyprlock/.config/hyprlock
mkdir -p ~/hypr-dot/hyprpaper/.config/hyprpaper
mkdir -p ~/hypr-dot/waybar/.config/waybar
mkdir -p ~/hypr-dot/wlogout/.config/wlogout
mkdir -p ~/hypr-dot/wofi/.config/wofi

# Now move all files to their new locations
mv ~/.config/dunst/* ~/hypr-dot/dunst/.config/dunst/
mv ~/.config/hypr/* ~/hypr-dot/hypr/.config/hypr/
mv ~/.config/hyprlock/* ~/hypr-dot/hyprlock/.config/hyprlock/
mv ~/.config/hyprpaper/* ~/hypr-dot/hyprpaper/.config/hyprpaper/
mv ~/.config/waybar/* ~/hypr-dot/waybar/.config/waybar/
mv ~/.config/wlogout/* ~/hypr-dot/wlogout/.config/wlogout/
mv ~/.config/wofi/* ~/hypr-dot/wofi/.config/wofi/

echo "Files have been moved to the new structure!"
echo "Check that everything moved correctly before we create symlinks"