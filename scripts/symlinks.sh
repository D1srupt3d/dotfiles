#!/bin/bash

# Define the base dotfiles directory
DOTFILES="$HOME/hypr-dot"

# Define configurations and their typical files
declare -A config_files=(
    ["dunst"]="dunstrc"
    ["hypr"]="hyprland.conf animations.conf keybinds.conf windowrules.conf"
    ["hyprlock"]="hyprlock.conf"
    ["hyprpaper"]="hyprpaper.conf"
    ["waybar"]="config style.css"
    ["wlogout"]="layout style.css"
    ["wofi"]="config style.css"
)

# Create the main dotfiles directory if it doesn't exist
mkdir -p "$DOTFILES"

# Function to create stow structure for each config
create_stow_structure() {
    local config=$1
    local src_dir="$HOME/.config/$config"
    local target_dir="$DOTFILES/$config/.config/$config"
    
    # Create the target directory structure
    mkdir -p "$target_dir"
    
    # If the source directory exists
    if [ -d "$src_dir" ]; then
        echo "Processing $config..."
        
        # Copy all files, including hidden ones
        cp -r "$src_dir"/. "$target_dir"/ 2>/dev/null
        
        # Remove original directory
        rm -rf "$src_dir"
        
        # Use stow to create symlinks
        cd "$DOTFILES"
        stow "$config"
        
        echo "✓ $config organized and linked"
    else
        echo "! $config directory not found in .config"
    fi
}

# First, make sure stow is installed
if ! command -v stow &> /dev/null; then
    echo "GNU Stow is not installed. Installing..."
    if command -v pacman &> /dev/null; then
        sudo pacman -S stow
    elif command -v apt &> /dev/null; then
        sudo apt install stow
    else
        echo "Could not install stow. Please install it manually."
        exit 1
    fi
fi

# Process each config
for config in "${!config_files[@]}"; do
    create_stow_structure "$config"
done

echo "
Organization complete! Your new structure is:

$DOTFILES/
├── dunst/
│   └── .config/
│       └── dunst/
│           └── dunstrc
├── hypr/
│   └── .config/
│       └── hypr/
│           ├── hyprland.conf
│           ├── animations.conf
│           ├── keybinds.conf
│           └── windowrules.conf
├── hyprlock/
│   └── .config/
│       └── hyprlock/
│           └── hyprlock.conf
├── hyprpaper/
│   └── .config/
│       └── hyprpaper/
│           └── hyprpaper.conf
├── waybar/
│   └── .config/
│       └── waybar/
│           ├── config
│           └── style.css
├── wlogout/
│   └── .config/
│       └── wlogout/
│           ├── layout
│           └── style.css
└── wofi/
    └── .config/
        └── wofi/
            ├── config
            └── style.css
"

echo "All configurations have been organized and symlinked using stow!"