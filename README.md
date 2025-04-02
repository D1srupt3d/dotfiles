# Hyprland Dotfiles

A collection of dotfiles for a modern Hyprland setup on Arch Linux.

## Components

- **Hyprland**: Modern Wayland compositor
- **Waybar**: Highly customizable status bar
- **Dunst**: Lightweight notification daemon
- **Wofi**: Application launcher
- **Wlogout**: Logout menu
- **Hyprpaper**: Wallpaper daemon for Hyprland

## Directory Structure

```
.
├── dunst/         # Notification daemon configuration
├── hypr/          # Hyprland configuration
├── scripts/       # Utility scripts
├── wallpapers/    # Wallpaper collection
├── waybar/        # Status bar configuration
├── wlogout/       # Logout menu configuration
└── wofi/          # Application launcher configuration
```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/hypr-dots.git
```

2. Copy the configurations to their respective locations:
```bash
cp -r dunst ~/.config/
cp -r hypr ~/.config/
cp -r waybar ~/.config/
cp -r wofi ~/.config/
cp -r wlogout ~/.config/
```

3. Install required dependencies:
```bash
sudo pacman -S hyprland waybar dunst wofi wlogout hyprpaper
```

## Features

- Modern Wayland compositor with Hyprland
- Customizable status bar with Waybar
- Notification system with Dunst
- Application launcher with Wofi
- Logout menu with Wlogout
- Wallpaper management with Hyprpaper

## Customization

Feel free to modify the configurations in each directory to match your preferences. The configurations are well-documented with comments explaining each section.
