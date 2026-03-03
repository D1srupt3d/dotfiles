#!/bin/bash

# switch-theme.sh - Internal script. Use setup.sh for interactive theme switching.
# Advanced usage: ./scripts/switch-theme.sh <theme-name>
# Example: ./scripts/switch-theme.sh dracula

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES_DIR="$DOTFILES_DIR/themes"
CURRENT_FILE="$THEMES_DIR/.current"

# ============================================================
# Usage / validation
# ============================================================
usage() {
    echo -e "${BOLD}Usage:${NC} switch-theme.sh <theme>"
    echo ""
    echo -e "${BOLD}Available themes:${NC}"
    for f in "$THEMES_DIR"/*.theme; do
        name=$(basename "$f" .theme)
        current=""
        [ -f "$CURRENT_FILE" ] && [ "$(cat "$CURRENT_FILE")" = "$name" ] && current=" ${GREEN}(active)${NC}"
        echo -e "  - $name$current"
    done
    exit 0
}

if [ -z "$1" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage
fi

THEME_NAME="$1"
THEME_FILE="$THEMES_DIR/$THEME_NAME.theme"

if [ ! -f "$THEME_FILE" ]; then
    echo -e "${RED}Error: Theme '$THEME_NAME' not found at $THEME_FILE${NC}"
    echo ""
    usage
fi

# ============================================================
# Load theme variables
# ============================================================
# shellcheck source=/dev/null
source "$THEME_FILE"

echo -e "${BLUE}${BOLD}Applying theme: $THEME_NAME${NC}\n"

# ============================================================
# Helper: replace content between THEME:START and THEME:END
# ============================================================
inject_block() {
    local file="$1"
    local new_content="$2"

    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}  ⚠ File not found: $file${NC}"
        return
    fi

    # Build the replacement using awk
    awk -v new="$new_content" '
        /THEME:START/ { print; print new; found=1; next }
        /THEME:END/   { if (found) { print; found=0 } next }
        !found        { print }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

    echo -e "${GREEN}  ✓ $(basename "$file")${NC}"
}

# ============================================================
# 1. Hyprland colors.conf
# ============================================================
echo -e "${BOLD}[1/6] Hyprland${NC}"

HYPR_COLORS_FILE="$DOTFILES_DIR/hypr/.config/hypr/conf/colors.conf"

inject_block "$HYPR_COLORS_FILE" "\
\$color_bg               = rgba(${BG//#/})ee)
\$color_surface          = rgba(${SURFACE//#/})ee)
\$color_surface2         = rgba(${SURFACE2//#/})ee)
\$color_accent           = rgba(${ACCENT//#/})ee)
\$color_border1          = rgba(${HYPR_BORDER1})
\$color_border2          = rgba(${HYPR_BORDER2})
\$color_border3          = rgba(${HYPR_BORDER3})
\$color_border_inactive  = rgba(${HYPR_BORDER_INACTIVE})
\$color_shadow           = rgba(${HYPR_SHADOW})"

# ============================================================
# 2. Waybar
# ============================================================
echo -e "\n${BOLD}[2/6] Waybar${NC}"

WAYBAR_CSS="$DOTFILES_DIR/waybar/.config/waybar/style.css"

inject_block "$WAYBAR_CSS" "\
@define-color wb_accent ${ACCENT};
@define-color wb_text ${TEXT};
@define-color wb_critical ${CRITICAL};
@define-color wb_spotify #1DB954;"

# ============================================================
# 3. Wofi
# ============================================================
echo -e "\n${BOLD}[3/6] Wofi${NC}"

WOFI_CSS="$DOTFILES_DIR/wofi/.config/wofi/style.css"

# Convert hex to rgb components for rgba() values
hex_to_rgb() {
    local hex="${1//#/}"
    printf "%d, %d, %d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

SURFACE_RGB=$(hex_to_rgb "$SURFACE")
SURFACE2_RGB=$(hex_to_rgb "$SURFACE2")

inject_block "$WOFI_CSS" "\
@define-color wofi_bg rgba(${SURFACE_RGB}, 0.95);
@define-color wofi_surface rgba(${SURFACE2_RGB}, 0.8);
@define-color wofi_border ${SURFACE2};
@define-color wofi_text ${TEXT};
@define-color wofi_shadow rgba(0, 0, 0, 0.2);"

# ============================================================
# 4. SwayNC
# ============================================================
echo -e "\n${BOLD}[4/6] SwayNC${NC}"

SWAYNC_CSS="$DOTFILES_DIR/swaync/.config/swaync/style.css"

inject_block "$SWAYNC_CSS" "\
@define-color cc-bg ${SURFACE}F0;
@define-color noti-border-color ${ACCENT2};
@define-color noti-bg ${SURFACE2}E6;
@define-color noti-bg-hover ${ACCENT}F0;
@define-color noti-bg-focus ${ACCENT2}F0;
@define-color noti-close-bg ${CRITICAL};
@define-color noti-close-bg-hover ${CRITICAL_HOVER};
@define-color text-color ${TEXT};
@define-color text-color-disabled ${TEXT_DIM};
@define-color critical ${CRITICAL};
@define-color warning ${WARNING};
@define-color info ${INFO};"

# ============================================================
# 5. Wlogout
# ============================================================
echo -e "\n${BOLD}[5/6] Wlogout${NC}"

WLOGOUT_CSS="$DOTFILES_DIR/wlogout/.config/wlogout/style.css"

BG_RGB=$(hex_to_rgb "$BG")
SURFACE_RGB=$(hex_to_rgb "$SURFACE")
SURFACE2_RGB=$(hex_to_rgb "$SURFACE2")
ACCENT_RGB=$(hex_to_rgb "$ACCENT")
BORDER_RGB=$(hex_to_rgb "$BORDER")
BORDER_BRIGHT_RGB=$(hex_to_rgb "$BORDER_BRIGHT")

inject_block "$WLOGOUT_CSS" "\
@define-color wl_bg rgba(${BG_RGB}, 0.95);
@define-color wl_btn_bg rgba(${SURFACE_RGB}, 0.5);
@define-color wl_btn_border rgba(${BORDER_RGB}, 0.6);
@define-color wl_btn_shadow rgba(0, 0, 0, 0.4);
@define-color wl_btn_bg_hover rgba(${ACCENT_RGB}, 0.7);
@define-color wl_btn_border_hover rgba(${BORDER_BRIGHT_RGB}, 0.9);
@define-color wl_btn_shadow_hover rgba(0, 0, 0, 0.6);
@define-color wl_text ${TEXT};"

# ============================================================
# 6. Ghostty
# ============================================================
echo -e "\n${BOLD}[+] Ghostty${NC}"

GHOSTTY_CONFIG="$DOTFILES_DIR/ghostty/.config/ghostty/config"

inject_block "$GHOSTTY_CONFIG" "\
background = ${GHOSTTY_BG}
foreground = ${GHOSTTY_FG}"

# ============================================================
# 6. Hyprlock
# ============================================================
echo -e "\n${BOLD}[6/6] Hyprlock${NC}"

HYPRLOCK_CONF="$DOTFILES_DIR/hypr/.config/hypr/hyprlock.conf"

inject_block "$HYPRLOCK_CONF" "\
\$hl_bg          = rgba(${BG//#/}cc)
\$hl_text        = rgba(${TEXT//#/}ff)
\$hl_text_dim    = rgba(${TEXT//#/}bb)
\$hl_text_dimmer = rgba(${TEXT//#/}77)
\$hl_accent      = rgba(${ACCENT2//#/}ff)
\$hl_border      = rgba(${BORDER//#/}ff)
\$hl_fail        = rgba(${CRITICAL//#/}ff)
\$hl_input_bg    = rgba(${SURFACE//#/}88)"

# ============================================================
# 7. Wallpaper
# ============================================================
echo -e "\n${BOLD}[+] Wallpaper${NC}"

if [ -n "$WALLPAPER" ]; then
    WALLPAPER_PATH="$DOTFILES_DIR/$WALLPAPER"
    if [ -f "$WALLPAPER_PATH" ]; then
        HYPRPAPER_CONF="$DOTFILES_DIR/hypr/.config/hypr/hyprpaper.conf"
        cat > "$HYPRPAPER_CONF" <<EOF
preload = $WALLPAPER_PATH
wallpaper = ,$WALLPAPER_PATH
splash = false
EOF
        echo -e "${GREEN}  ✓ hyprpaper.conf${NC}"
    else
        echo -e "${YELLOW}  ⚠ Wallpaper not found: $WALLPAPER_PATH${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠ No WALLPAPER set in theme file${NC}"
fi

# ============================================================
# Save current theme
# ============================================================
echo "$THEME_NAME" > "$CURRENT_FILE"

# ============================================================
# Live reload
# ============================================================
echo -e "\n${BOLD}Reloading...${NC}"

# Hyprland
if command -v hyprctl &>/dev/null; then
    hyprctl reload &>/dev/null && echo -e "${GREEN}  ✓ Hyprland${NC}" || echo -e "${YELLOW}  ⚠ Hyprland reload failed${NC}"
fi

# Waybar
if pgrep waybar &>/dev/null; then
    pkill -SIGUSR2 waybar && echo -e "${GREEN}  ✓ Waybar${NC}" || echo -e "${YELLOW}  ⚠ Waybar reload failed${NC}"
fi

# SwayNC
if pgrep swaync &>/dev/null; then
    swaync-client --reload-config &>/dev/null && echo -e "${GREEN}  ✓ SwayNC${NC}" || echo -e "${YELLOW}  ⚠ SwayNC reload failed${NC}"
fi

# Hyprpaper
if command -v hyprctl &>/dev/null && [ -n "$WALLPAPER" ]; then
    WALLPAPER_PATH="$DOTFILES_DIR/$WALLPAPER"
    pkill hyprpaper 2>/dev/null; sleep 0.5
    hyprpaper &>/dev/null &
    sleep 1
    hyprctl hyprpaper preload "$WALLPAPER_PATH" &>/dev/null
    hyprctl hyprpaper wallpaper ",$WALLPAPER_PATH" &>/dev/null \
        && echo -e "${GREEN}  ✓ Wallpaper${NC}" \
        || echo -e "${YELLOW}  ⚠ Wallpaper reload failed${NC}"
fi

echo -e "\n${GREEN}${BOLD}Theme '$THEME_NAME' applied!${NC}"
echo -e "${YELLOW}Note: Wofi and Wlogout will use the new theme on next launch.${NC}"
echo -e "${YELLOW}Note: Ghostty will use the new theme in new windows.${NC}\n"
