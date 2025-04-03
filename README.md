# Hyprland Dotfiles

A collection of dotfiles for a modern Hyprland setup on Arch Linux.

## Components

- **Hyprland**: Modern Wayland compositor
- **Waybar**: Highly customizable status bar
- **Dunst**: Lightweight notification daemon
- **Wofi**: Application launcher
- **Wlogout**: Logout menu
- **Btop**: System monitor
- **Fastfetch**: System information tool
- **Ghpstty**: Terminal configuration
- **Rofi**: Application launcher (alternative to Wofi)
- **Thunar**: File manager
- **Hyprshot**: Screenshot tool
- **Hyprlock**: Screen locker
- **Hyprpaper**: Wallpaper daemon
- **Hypridle**: Idle management tool

## Directory Structure

```
.
├── btop/          # System monitor configuration
├── dunst/         # Notification daemon configuration
├── fastfetch/     # System information configuration
├── ghpstty/       # Terminal configuration
├── hypr/          # Hyprland configuration
├── rofi/          # Application launcher configuration
├── scripts/       # Utility scripts
├── wallpapers/    # Wallpaper collection
├── waybar/        # Status bar configuration
├── wlogout/       # Logout menu configuration
├── wofi/          # Application launcher configuration
├── thunar/        # File manager configuration
├── hyprshot/      # Screenshot tool configuration
├── hyprlock/      # Screen locker configuration
├── hyprpaper/     # Wallpaper daemon configuration
└── hypridle/      # Idle management tool configuration
```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/hypr-dots.git
cd hypr-dots
```

2. Install gitstow:
```bash
sudo pacman -S gitstow
```

3. Install required dependencies:
```bash
sudo pacman -S hyprland waybar dunst wofi wlogout btop fastfetch ghostty rofi thunar hyprshot hyprlock hyprpaper hypridle
```

4. Use gitstow to symlink the configurations:
```bash
gitstow btop dunst fastfetch ghpstty hypr rofi waybar wlogout wofi thunar hyprshot hyprlock hyprpaper hypridle
```

## Features

- Modern Wayland compositor with Hyprland
- Customizable status bar with Waybar
- Notification system with Dunst
- Application launchers with both Wofi and Rofi
- Logout menu with Wlogout
- System monitoring with Btop
- System information display with Fastfetch
- Terminal configuration with Ghpstty

## Customization

Feel free to modify the configurations in each directory to match your preferences. The configurations are well-documented with comments explaining each section.
