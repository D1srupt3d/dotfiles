#!/bin/bash

# Create base directory
mkdir -p ~/hypr-dot

# Create dunst structure
mkdir -p ~/hypr-dot/dunst/.config/dunst

# Create hypr structure with all your conf files
mkdir -p ~/hypr-dot/hypr/.config/hypr/conf
mkdir -p ~/hypr-dot/hypr/.config/hypr/hyprlock

# Create waybar structure
mkdir -p ~/hypr-dot/waybar/.config/waybar

# Create wlogout structure with icons
mkdir -p ~/hypr-dot/wlogout/.config/wlogout/icons

# Create wofi structure
mkdir -p ~/hypr-dot/wofi/.config/wofi

# Copy all files to their new locations
cp ~/.config/dunst/dunstrc ~/hypr-dot/dunst/.config/dunst/

# Copy hypr files
cp ~/.config/hypr/hyprland.conf ~/hypr-dot/hypr/.config/hypr/
cp ~/.config/hypr/hyprlock.conf ~/hypr-dot/hypr/.config/hypr/
cp ~/.config/hypr/hyprpaper.conf ~/hypr-dot/hypr/.config/hypr/
cp ~/.config/hypr/hyprlock/theme.conf ~/hypr-dot/hypr/.config/hypr/hyprlock/
cp ~/.config/hypr/conf/* ~/hypr-dot/hypr/.config/hypr/conf/

# Copy waybar files
cp ~/.config/waybar/{config,style.css} ~/hypr-dot/waybar/.config/waybar/

# Copy wlogout files
cp ~/.config/wlogout/{layout,style.css} ~/hypr-dot/wlogout/.config/wlogout/
cp ~/.config/wlogout/icons/* ~/hypr-dot/wlogout/.config/wlogout/icons/

# Copy wofi files
cp ~/.config/wofi/{config,style.css} ~/hypr-dot/wofi/.config/wofi/

echo "Directory structure created and files copied!"