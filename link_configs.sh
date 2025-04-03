#!/bin/bash

# Create symbolic links for all configurations
ln -sf ~/Documents/hypr-dots/btop/.config/btop ~/.config/btop
ln -sf ~/Documents/hypr-dots/dunst/.config/dunst ~/.config/dunst
ln -sf ~/Documents/hypr-dots/fastfetch/.config/fastfetch ~/.config/fastfetch
ln -sf ~/Documents/hypr-dots/ghostty/.config/ghostty ~/.config/ghostty
ln -sf ~/Documents/hypr-dots/hypr/.config/hypr ~/.config/hypr
ln -sf ~/Documents/hypr-dots/rofi/.config/rofi ~/.config/rofi
ln -sf ~/Documents/hypr-dots/waybar/.config/waybar ~/.config/waybar
ln -sf ~/Documents/hypr-dots/wlogout/.config/wlogout ~/.config/wlogout
ln -sf ~/Documents/hypr-dots/wofi/.config/wofi ~/.config/wofi

echo "All configurations have been linked to ~/.config" 