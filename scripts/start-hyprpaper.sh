#!/bin/bash
# Regenerates hyprpaper.conf for the current monitors + theme, then launches hyprpaper.
# Called from autostart.conf so wallpaper always matches hardware.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURRENT_FILE="$DOTFILES_DIR/themes/.current"
HYPRPAPER_CONF="$DOTFILES_DIR/hypr/.config/hypr/hyprpaper.conf"

# Read current theme name (default to first available theme if unset)
THEME_NAME=""
[ -f "$CURRENT_FILE" ] && THEME_NAME="$(cat "$CURRENT_FILE" | tr -d '[:space:]')"
if [ -z "$THEME_NAME" ]; then
    THEME_NAME="$(ls "$DOTFILES_DIR/themes/"*.theme 2>/dev/null | head -1 | xargs basename | sed 's/\.theme//')"
fi

THEME_FILE="$DOTFILES_DIR/themes/${THEME_NAME}.theme"
if [ ! -f "$THEME_FILE" ]; then
    echo "start-hyprpaper: theme file not found: $THEME_FILE" >&2
    exec hyprpaper
fi

# Source theme to get WALLPAPER variable
source "$THEME_FILE"

WALLPAPER_PATH="$DOTFILES_DIR/$WALLPAPER"
if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "start-hyprpaper: wallpaper not found: $WALLPAPER_PATH" >&2
    exec hyprpaper
fi

# Detect connected monitors — wait briefly for Hyprland to register them
sleep 1
MONITORS=$(hyprctl monitors -j 2>/dev/null | grep -oP '"name":\s*"\K[^"]+')

# Build hyprpaper.conf
{
    echo "preload = $WALLPAPER_PATH"
    if [ -n "$MONITORS" ]; then
        while IFS= read -r mon; do
            echo "wallpaper = ${mon},${WALLPAPER_PATH}"
        done <<< "$MONITORS"
    else
        # Fallback if hyprctl isn't ready yet
        echo "wallpaper = ,${WALLPAPER_PATH}"
    fi
    echo "splash = false"
} > "$HYPRPAPER_CONF"

exec hyprpaper
