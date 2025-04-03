# Hyprland Dotfiles

A collection of dotfiles for a modern Hyprland setup on Arch Linux.

## 🖼️ Screenshots

![Desktop](assets/screenshots/desktop.png)
*Main desktop with Waybar and Wofi*

![Lock Screen](assets/screenshots/lock.png)
*Lock screen with Hyprlock*

![Terminal](assets/screenshots/terminal.png)
*Terminal with custom prompt and ASCII art*

## Components

- **Hyprland**: Modern Wayland compositor
- **Waybar**: Highly customizable status bar
- **Dunst**: Lightweight notification daemon
- **Wofi**: Application launcher
- **Wlogout**: Logout menu
- **Btop**: System monitor
- **Fastfetch**: System information tool with custom ASCII art
- **Ghostty**: Modern terminal emulator with Tokyo Night theme
- **Thunar**: File manager
- **Hyprshot**: Screenshot tool
- **Hyprlock**: Screen locker
- **Hyprpaper**: Wallpaper daemon
- **Hypridle**: Idle management tool
- **Starship**: Cross-shell prompt with system information
- **Zsh**: Shell configuration with custom aliases and functions

## Directory Structure

```
.
├── btop/          # System monitor configuration
├── dunst/         # Notification daemon configuration
├── fastfetch/     # System information configuration with custom ASCII art
├── ghostty/       # Terminal configuration with Tokyo Night theme
├── hypr/          # Hyprland configuration
├── scripts/       # Utility scripts
├── wallpapers/    # Wallpaper collection
├── waybar/        # Status bar configuration
├── wlogout/       # Logout menu configuration
├── wofi/          # Application launcher configuration
├── thunar/        # File manager configuration
├── hyprshot/      # Screenshot tool configuration
├── hyprlock/      # Screen locker configuration
├── hyprpaper/     # Wallpaper daemon configuration
├── hypridle/      # Idle management tool configuration
├── starship/      # Cross-shell prompt configuration
└── zsh/           # Shell configuration with custom aliases
```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/D1srupt3d/hypr-dots.git
cd hypr-dots
```

2. Install gitstow:
```bash
sudo pacman -S gitstow
```

3. Install required dependencies:
```bash
sudo pacman -S hyprland waybar dunst wofi wlogout btop fastfetch ghostty thunar hyprshot hyprlock hyprpaper hypridle starship zsh
```

4. Use git stow to symlink the configurations:
```bash
stow -v -t ~ btop dunst fastfetch ghostty hypr rofi waybar wlogout wofi thunar hyprshot hyprlock hyprpaper hypridle starship zsh
```

## Features

- Modern Wayland compositor with Hyprland
- Customizable status bar with Waybar
- Notification system with Dunst
- Application launchers with Wofi
- Logout menu with Wlogout
- System monitoring with Btop
- System information display with Fastfetch and custom ASCII art
- Terminal configuration with Ghostty and Tokyo Night theme
- Cross-shell prompt with Starship
- Custom Zsh configuration with aliases and functions
- Screenshot tool with Hyprshot
- Screen locker with Hyprlock
- Wallpaper management with Hyprpaper
- Idle management with Hypridle

## Customization

Feel free to modify the configurations in each directory to match your preferences. The configurations are well-documented with comments explaining each section.

### Terminal Theme
The Ghostty terminal uses the Tokyo Night theme with:
- Background: #1a1b26 with 85% opacity
- Foreground: #a9b1d6
- Custom font: Hack Nerd Font

### Fastfetch
Includes amy custom ASCII art logo for "D1rupt3d"

### Starship Prompt
Configured with:
- System information display
- Programming language support
- Git status
- Custom sections for automation tools

### Zsh Configuration
Includes:
- Custom aliases for common commands
- Function for creating and entering directories
- Improved history settings
- Better tab completion
