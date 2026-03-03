#!/bin/bash

# =============================================================
# d1srupt3d dotfiles — interactive setup wizard
# Run this to install or theme your Hyprland desktop.
# =============================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
THEMES_DIR="$DOTFILES_DIR/themes"

# ── Color palette ─────────────────────────────────────────────
RST='\033[0m'; BOLD='\033[1m'; DIM='\033[2m'
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'
B='\033[1;34m'; P='\033[1;35m'; C='\033[1;36m'; W='\033[1;37m'

# ── Whiptail color scheme ─────────────────────────────────────
export NEWT_COLORS='
root=white,black
border=cyan,black
title=cyan,black
roottext=white,black
window=white,black
textbox=white,black
button=black,cyan
actbutton=black,white
compactbutton=white,black
listbox=white,black
actlistbox=black,cyan
actsellistbox=black,cyan
checkbox=white,black
actcheckbox=black,cyan
entry=white,black
disentry=black,black
shadow=black,black
label=white,black
'

# ── Helpers ───────────────────────────────────────────────────
banner() {
    clear
    echo -e "${C}${BOLD}"
    echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
    echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
    echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
    echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
    echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
    echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
    echo -e "${RST}"
    echo -e "  ${DIM}by d1srupt3d  ·  hyprland · waybar · ghostty · wofi · swaync${RST}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────────${RST}"
    echo ""
}

step()  { echo -e "\n  ${C}${BOLD}::${RST}  ${BOLD}$*${RST}"; }
ok()    { echo -e "     ${G}✓${RST}  $*"; }
warn()  { echo -e "     ${Y}⚠${RST}  $*"; }
fail()  { echo -e "     ${R}✗${RST}  $*"; }
info()  { echo -e "     ${DIM}·  $*${RST}"; }
div()   { echo -e "\n  ${DIM}────────────────────────────────────────────────────────────${RST}"; }

spinner() {
    local pid=$1 msg=$2
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    tput civis 2>/dev/null
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r     ${C}%s${RST}  %s" "${frames[$i]}" "$msg"
        i=$(( (i+1) % 10 ))
        sleep 0.08
    done
    tput cnorm 2>/dev/null
    printf "\r"
}

# ── Sanity checks ─────────────────────────────────────────────
banner

if [ ! -f /etc/arch-release ]; then
    fail "This setup is designed for Arch Linux."; echo; exit 1
fi
if [ "$EUID" -eq 0 ]; then
    fail "Do not run as root — run as your normal user."; echo; exit 1
fi
if ! command -v whiptail &>/dev/null; then
    fail "whiptail not found. Install it: ${C}sudo pacman -S libnewt${RST}"; echo; exit 1
fi

# ── Terminal size ─────────────────────────────────────────────
TERM_H=$(tput lines); TERM_W=$(tput cols)
BOX_H=$(( TERM_H > 30 ? 28 : TERM_H - 4 ))
BOX_W=$(( TERM_W > 80 ? 76 : TERM_W - 4 ))

# =============================================================
# SCREEN 1 — Welcome
# =============================================================
whiptail --title "  d1srupt3d dotfiles  " \
    --msgbox "\n  Welcome!\n\n  This wizard will set up your Hyprland desktop.\n\n  You can:\n\n    ·  Do a fresh install\n    ·  Switch color themes\n    ·  Add or remove components\n\n  Nothing changes until you confirm at the end.\n\n  Press Enter to get started." \
    $BOX_H $BOX_W

[ $? -ne 0 ] && { echo; exit 0; }

# =============================================================
# SCREEN 2 — Mode
# =============================================================
MODE=$(whiptail --title "  What would you like to do?  " \
    --radiolist "  Use arrow keys · Space to select · Enter to confirm\n" \
    $BOX_H $BOX_W 3 \
    "install"  "Fresh install  — set up Hyprland for the first time"  ON  \
    "theme"    "Change theme   — already set up, just want new colors" OFF \
    "manage"   "Add / remove   — change which components are installed" OFF \
    3>&1 1>&2 2>&3)

[ $? -ne 0 ] && { echo; exit 0; }

# =============================================================
# SCREEN 3 — Component selection (skipped for theme-only)
# =============================================================
SELECTED_COMPONENTS=()

if [ "$MODE" != "theme" ]; then

    is_stowed() { [ -L "$HOME/.config/$1" ] || [ -L "$HOME/$1" ]; }

    COMPONENTS=$(whiptail --title "  Choose what to install  " \
        --checklist "  Space to check/uncheck · Enter to confirm\n" \
        $BOX_H $BOX_W 10 \
        "hypr"      "Hyprland       — window manager (required)"          ON  \
        "waybar"    "Waybar         — top bar with clock, battery, info"  ON  \
        "swaync"    "SwayNC         — notification popups + control center" ON \
        "wofi"      "Wofi           — app launcher (Super+Space)"         ON  \
        "wlogout"   "Wlogout        — power menu (shutdown, lock, reboot)" ON \
        "ghostty"   "Ghostty        — terminal emulator"                  ON  \
        "zshrc"     "Zsh & Starship — shell config with a styled prompt"  ON  \
        "btop"      "btop           — live CPU, RAM and disk monitor"     ON  \
        "starship"  "Starship       — cross-shell prompt theme"           ON  \
        "fastfetch" "Fastfetch      — system info on terminal open"       OFF \
        3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && { echo; exit 0; }

    for item in $COMPONENTS; do
        SELECTED_COMPONENTS+=("${item//\"/}")
    done

    if [ ${#SELECTED_COMPONENTS[@]} -eq 0 ] && [ "$MODE" = "install" ]; then
        whiptail --title "  Nothing selected  " \
            --msgbox "\n  You didn't select any components.\n\n  Run setup again and pick at least one." \
            $BOX_H $BOX_W
        exit 0
    fi
fi

# =============================================================
# SCREEN 4 — Theme picker
# =============================================================
banner

echo -e "  ${BOLD}${W}Color themes${RST}  ${DIM}— pick one below${RST}"
echo ""

swatch() {
    local name="$1"; shift
    printf "  %-22s" "$name"
    for col in "$@"; do
        local r=$(( 16#${col:1:2} ))
        local g=$(( 16#${col:3:2} ))
        local b=$(( 16#${col:5:2} ))
        printf "\e[48;2;%d;%d;%dm   \e[0m" "$r" "$g" "$b"
    done
    echo ""
}

swatch "  Graphite"          "#1a1a1a" "#3a3a3a" "#808080" "#aaaaaa" "#ffffff"
swatch "  Catppuccin Mocha"  "#1e1e2e" "#313244" "#cba6f7" "#f38ba8" "#cdd6f4"
swatch "  Catppuccin Latte"  "#eff1f5" "#dce0e8" "#7287fd" "#d20f39" "#4c4f69"
swatch "  Nord"              "#2e3440" "#434c5e" "#81a1c1" "#88c0d0" "#eceff4"
swatch "  Dracula"           "#282a36" "#44475a" "#bd93f9" "#ff79c6" "#f8f8f2"
swatch "  Tokyo Night"       "#1a1b26" "#2f3549" "#7aa2f7" "#bb9af7" "#c0caf5"
swatch "  Rose Pine"         "#191724" "#26233a" "#c4a7e7" "#eb6f92" "#e0def4"
swatch "  Gruvbox"           "#282828" "#504945" "#d79921" "#fb4934" "#ebdbb2"
swatch "  Everforest"        "#2f383e" "#404c51" "#83c092" "#a7c080" "#d3c6aa"

echo ""
echo -e "  ${DIM}Press Enter to open the selector…${RST}"
read -rsp "" _

CURRENT_THEME="graphite"
[ -f "$THEMES_DIR/.current" ] && CURRENT_THEME=$(cat "$THEMES_DIR/.current")
make_state() { [ "$1" = "$CURRENT_THEME" ] && echo ON || echo OFF; }

THEME=$(whiptail --title "  Pick a theme  " \
    --radiolist "  Current: ${CURRENT_THEME}  ·  Arrow keys · Space · Enter\n" \
    $BOX_H $BOX_W 9 \
    "graphite"         "  Graphite        — dark gray and white"               $(make_state graphite)         \
    "catppuccin-mocha" "  Catppuccin Mocha — dark with soft purple and pink"   $(make_state catppuccin-mocha) \
    "catppuccin-latte" "  Catppuccin Latte — light, warm and creamy"           $(make_state catppuccin-latte) \
    "nord"             "  Nord             — arctic blues and cool slate"       $(make_state nord)             \
    "dracula"          "  Dracula          — dark purple with pink and cyan"    $(make_state dracula)          \
    "tokyo-night"      "  Tokyo Night      — deep navy with purple glow"       $(make_state tokyo-night)      \
    "rose-pine"        "  Rose Pine        — dark lavender and rose tones"     $(make_state rose-pine)        \
    "gruvbox"          "  Gruvbox          — warm retro oranges on dark brown" $(make_state gruvbox)          \
    "everforest"       "  Everforest       — muted greens and earthy tones"    $(make_state everforest)       \
    3>&1 1>&2 2>&3)

[ $? -ne 0 ] && { echo; exit 0; }
THEME="${THEME//\"/}"

# =============================================================
# SCREEN 5 — Confirm
# =============================================================
if [ "$MODE" = "theme" ]; then
    SUMMARY="  Ready to apply theme: ${THEME}\n\n  · Updates colors in all configs\n  · Reloads Waybar, Hyprland, SwayNC\n  · Sets the matching wallpaper\n\n  Press OK to apply."
else
    COMP_LIST=$(IFS=', '; echo "${SELECTED_COMPONENTS[*]}")
    SUMMARY="  Ready to install!\n\n  Components  :  ${COMP_LIST}\n  Theme       :  ${THEME}\n  AUR helper  :  paru (installed if missing)\n\n  Existing configs will be backed up first.\n\n  Press OK to begin."
fi

whiptail --title "  Confirm  " \
    --yesno "$SUMMARY" \
    $BOX_H $BOX_W \
    --yes-button "  Let's go!  " --no-button "  Cancel  "

[ $? -ne 0 ] && { echo; exit 0; }

# =============================================================
# EXECUTE
# =============================================================
banner

# ── Install packages ──────────────────────────────────────────
if [ "$MODE" != "theme" ] && [ ${#SELECTED_COMPONENTS[@]} -gt 0 ]; then

    step "Installing packages"

    declare -A PKG_MAP
    PKG_MAP["hypr"]="hyprland hyprpaper hyprlock hypridle xdg-desktop-portal-hyprland"
    PKG_MAP["waybar"]="waybar"
    PKG_MAP["swaync"]="swaync"
    PKG_MAP["wofi"]="wofi"
    PKG_MAP["wlogout"]=""
    PKG_MAP["ghostty"]=""
    PKG_MAP["zshrc"]="zsh"
    PKG_MAP["btop"]="btop"
    PKG_MAP["starship"]="starship"
    PKG_MAP["fastfetch"]="fastfetch"

    declare -A AUR_MAP
    AUR_MAP["wlogout"]="wlogout"
    AUR_MAP["ghostty"]="ghostty"

    OFFICIAL_PKGS=("wayland" "wl-clipboard" "git" "stow"
                   "pipewire" "wireplumber" "pipewire-pulse"
                   "brightnessctl" "ttf-hack-nerd" "noto-fonts-emoji"
                   "hyprpicker" "polkit-kde-agent")
    AUR_PKGS=()

    for comp in "${SELECTED_COMPONENTS[@]}"; do
        [ -n "${PKG_MAP[$comp]}" ] && read -ra pkgs <<< "${PKG_MAP[$comp]}" && OFFICIAL_PKGS+=("${pkgs[@]}")
        [ -n "${AUR_MAP[$comp]}" ] && AUR_PKGS+=("${AUR_MAP[$comp]}")
    done

    MISSING=()
    for pkg in "${OFFICIAL_PKGS[@]}"; do
        pacman -Qi "$pkg" &>/dev/null || MISSING+=("$pkg")
    done

    if [ ${#MISSING[@]} -gt 0 ]; then
        info "Installing ${#MISSING[@]} packages from official repos…"
        sudo pacman -S --needed --noconfirm "${MISSING[@]}" &
        spinner $! "pacman -S ${MISSING[*]}"
        wait $! && ok "Official packages installed" || { fail "pacman failed"; exit 1; }
    else
        ok "All official packages already installed"
    fi

    if [ ${#AUR_PKGS[@]} -gt 0 ] && ! command -v paru &>/dev/null; then
        info "Installing paru (AUR helper)…"
        git clone https://aur.archlinux.org/paru.git /tmp/paru-setup &>/dev/null &
        spinner $! "Cloning paru…"
        (cd /tmp/paru-setup && makepkg -si --noconfirm &>/dev/null) &
        spinner $! "Building paru…"
        rm -rf /tmp/paru-setup
        ok "paru installed"
    fi

    if [ ${#AUR_PKGS[@]} -gt 0 ]; then
        MISSING_AUR=()
        for pkg in "${AUR_PKGS[@]}"; do
            pacman -Qi "$pkg" &>/dev/null || MISSING_AUR+=("$pkg")
        done
        if [ ${#MISSING_AUR[@]} -gt 0 ]; then
            info "Installing ${#MISSING_AUR[@]} AUR packages…"
            paru -S --needed --noconfirm "${MISSING_AUR[@]}" &
            spinner $! "paru -S ${MISSING_AUR[*]}"
            wait $! && ok "AUR packages installed"
        else
            ok "All AUR packages already installed"
        fi
    fi

    step "Enabling services"
    sudo systemctl enable --now bluetooth.service   &>/dev/null && ok "Bluetooth" || warn "Bluetooth failed"
    sudo systemctl enable --now NetworkManager.service &>/dev/null && ok "NetworkManager" || warn "NetworkManager failed"

    if [[ " ${SELECTED_COMPONENTS[*]} " == *" zshrc "* ]]; then
        if [ "$SHELL" != "$(which zsh)" ]; then
            chsh -s "$(which zsh)" && ok "Zsh set as default shell" || warn "Could not set Zsh as default"
        else
            ok "Zsh already default shell"
        fi
    fi
fi

# ── Apply theme ───────────────────────────────────────────────
step "Applying theme  ${C}${THEME}${RST}"
"$SCRIPTS_DIR/switch-theme.sh" "$THEME"

# ── Stow configs ──────────────────────────────────────────────
if [ "$MODE" != "theme" ] && [ ${#SELECTED_COMPONENTS[@]} -gt 0 ]; then
    step "Linking config files"
    for comp in "${SELECTED_COMPONENTS[@]}"; do
        if [ -d "$DOTFILES_DIR/$comp" ]; then
            target_dir="$HOME/.config/$comp"
            if [ -d "$target_dir" ] && [ ! -L "$target_dir" ]; then
                mv "$target_dir" "${target_dir}.bak.$(date +%s)"
                warn "Backed up existing ${comp} config"
            fi
            stow -d "$DOTFILES_DIR" -t ~ "$comp" 2>/dev/null \
                && ok "$comp" \
                || warn "$comp — some files already exist (skipped)"
        fi
    done
fi

# =============================================================
# Done
# =============================================================
div
echo ""
echo -e "  ${G}${BOLD}✓  Theme applied: ${THEME}${RST}"
echo ""
echo -e "  ${DIM}Key shortcuts${RST}"
echo -e "  ${C}Super + Space${RST}   app launcher"
echo -e "  ${C}Super + Enter${RST}   terminal"
echo -e "  ${C}Super + B${RST}       browser"
echo -e "  ${C}Super + N${RST}       notifications"
echo -e "  ${C}Super + L${RST}       lock screen"
echo -e "  ${C}Super + Q${RST}       close window"
echo ""
div
echo ""
