#!/bin/bash

# =============================================================
# Hyprland Dotfiles - Package Installer
# =============================================================
# Can be called directly for a non-interactive install,
# or sourced as a library by setup.sh.
#
# Usage:
#   ./scripts/install.sh [--dry-run] [--yes]
#
# For the interactive wizard, run ./setup.sh instead.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

DRY_RUN=false
AUTO_YES=false

# ── Argument parsing ──────────────────────────────────────────
usage() {
    echo -e "${BOLD}Usage:${NC} install.sh [options]"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo "  --dry-run    Show what would be installed without making changes"
    echo "  --yes        Skip confirmation prompt"
    echo "  --help       Show this message"
    echo ""
    echo -e "  For the interactive setup wizard, run ${BOLD}./setup.sh${NC} instead."
    exit 0
}

for arg in "$@"; do
    case $arg in
        --dry-run) DRY_RUN=true ;;
        --yes|-y)  AUTO_YES=true ;;
        --help|-h) usage ;;
        *) echo -e "${RED}Unknown option: $arg${NC}"; usage ;;
    esac
done

# ── Helpers ───────────────────────────────────────────────────
run() { [ "$DRY_RUN" = false ] && "$@"; }

log_would() { [ "$DRY_RUN" = true ] && echo -e "${YELLOW}  [dry-run] $1${NC}"; }

pkg_installed() { pacman -Qi "$1" &>/dev/null; }

# ── Package lists ─────────────────────────────────────────────
OFFICIAL_PACKAGES=(
    # Hyprland ecosystem
    hyprland hyprpaper hyprlock hypridle xdg-desktop-portal-hyprland

    # Wayland
    wayland wl-clipboard

    # Bar, notifications, launcher
    waybar swaync wofi

    # File manager
    nautilus

    # Terminal tools
    btop fastfetch

    # Shell
    zsh starship

    # Screenshots
    grim slurp

    # Audio
    pipewire wireplumber pipewire-audio pipewire-pulse

    # Bluetooth
    bluez bluez-utils

    # Network
    networkmanager

    # Brightness
    brightnessctl

    # Fonts
    ttf-hack-nerd noto-fonts-emoji

    # Utilities
    hyprpicker polkit-kde-agent stow git firefox
)

AUR_REQUIRED=(
    ghostty     # Terminal
    hyprshot    # Screenshots
    wlogout     # Logout menu
)

AUR_OPTIONAL=(
    1password
    spotify
)

# ── Install official packages ─────────────────────────────────
install_official() {
    echo -e "${GREEN}${BOLD}Official packages${NC}"

    MISSING=()
    for pkg in "${OFFICIAL_PACKAGES[@]}"; do
        pkg_installed "$pkg" || MISSING+=("$pkg")
    done

    if [ ${#MISSING[@]} -eq 0 ]; then
        echo -e "${BLUE}  ✓ All packages already installed${NC}"
    else
        echo -e "${GREEN}  → Installing ${#MISSING[@]} packages:${NC}"
        printf '    - %s\n' "${MISSING[@]}"
        run sudo pacman -S --needed --noconfirm "${MISSING[@]}"
        log_would "sudo pacman -S --needed ${MISSING[*]}"
    fi
}

# ── Install paru ──────────────────────────────────────────────
install_paru() {
    echo -e "${GREEN}${BOLD}AUR helper (paru)${NC}"

    if command -v paru &>/dev/null; then
        echo -e "${BLUE}  ✓ paru already installed${NC}"
        return
    fi

    log_would "Install paru from AUR" && return

    echo -e "${GREEN}  → Installing paru...${NC}"
    git clone https://aur.archlinux.org/paru.git /tmp/paru-setup
    (cd /tmp/paru-setup && makepkg -si --noconfirm)
    rm -rf /tmp/paru-setup
}

# ── Install AUR packages ──────────────────────────────────────
install_aur() {
    echo -e "${GREEN}${BOLD}AUR packages${NC}"

    MISSING_AUR=()
    for pkg in "${AUR_REQUIRED[@]}"; do
        pkg_installed "$pkg" || MISSING_AUR+=("$pkg")
    done

    MISSING_OPT=()
    for pkg in "${AUR_OPTIONAL[@]}"; do
        pkg_installed "$pkg" || MISSING_OPT+=("$pkg")
    done

    if [ ${#MISSING_AUR[@]} -gt 0 ]; then
        echo -e "${GREEN}  → Installing ${#MISSING_AUR[@]} required AUR packages:${NC}"
        printf '    - %s\n' "${MISSING_AUR[@]}"
        run paru -S --needed --noconfirm "${MISSING_AUR[@]}"
        log_would "paru -S --needed ${MISSING_AUR[*]}"
    else
        echo -e "${BLUE}  ✓ Required AUR packages already installed${NC}"
    fi

    if [ ${#MISSING_OPT[@]} -gt 0 ]; then
        echo -e "${YELLOW}  → Installing ${#MISSING_OPT[@]} optional packages:${NC}"
        printf '    - %s\n' "${MISSING_OPT[@]}"
        if [ "$DRY_RUN" = false ]; then
            for pkg in "${MISSING_OPT[@]}"; do
                paru -S --needed --noconfirm "$pkg" || echo -e "${YELLOW}    ⚠ Skipped $pkg${NC}"
            done
        fi
    fi
}

# ── Enable services ───────────────────────────────────────────
enable_services() {
    echo -e "${GREEN}${BOLD}System services${NC}"
    for svc in bluetooth.service NetworkManager.service; do
        if systemctl is-enabled "$svc" &>/dev/null; then
            echo -e "${BLUE}  ✓ $svc already enabled${NC}"
        else
            echo -e "${GREEN}  → Enabling $svc${NC}"
            run sudo systemctl enable --now "$svc"
            log_would "systemctl enable --now $svc"
        fi
    done
}

# ── Set default shell ─────────────────────────────────────────
set_shell() {
    echo -e "${GREEN}${BOLD}Default shell${NC}"
    if [ "$SHELL" = "$(which zsh)" ]; then
        echo -e "${BLUE}  ✓ zsh is already the default shell${NC}"
    else
        echo -e "${GREEN}  → Setting zsh as default shell${NC}"
        run chsh -s "$(which zsh)"
        log_would "chsh -s $(which zsh)"
    fi
}

# ── Stow dotfiles ─────────────────────────────────────────────
stow_all() {
    local dotfiles_dir="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
    echo -e "${GREEN}${BOLD}Symlinking dotfiles${NC}"

    STOW_DIRS=(btop fastfetch ghostty hypr starship swaync waybar wofi wlogout zshrc)

    for dir in "${STOW_DIRS[@]}"; do
        [ -d "$dotfiles_dir/$dir" ] || { echo -e "${YELLOW}  ⚠ $dir not found, skipping${NC}"; continue; }
        if [ "$DRY_RUN" = false ]; then
            stow -d "$dotfiles_dir" -t ~ "$dir" 2>/dev/null \
                && echo -e "${GREEN}  ✓ $dir${NC}" \
                || echo -e "${YELLOW}  ⚠ $dir has conflicts${NC}"
        else
            log_would "stow $dir"
        fi
    done
}

# =============================================================
# Run directly (not sourced)
# =============================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    echo -e "${BLUE}${BOLD}"
    echo "  ██╗  ██╗██╗   ██╗██████╗ ██████╗"
    echo "  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗"
    echo "  ███████║ ╚████╔╝ ██████╔╝██████╔╝"
    echo "  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗"
    echo "  ██║  ██║   ██║   ██║     ██║  ██║"
    echo "  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝"
    echo -e "${NC}${BLUE}  Dotfiles - Non-interactive installer${NC}\n"
    echo -e "  ${YELLOW}For the guided setup wizard, run: ${BOLD}./setup.sh${NC}\n"

    [ "$DRY_RUN" = true ] && echo -e "${YELLOW}${BOLD}  DRY RUN — no changes will be made${NC}\n"

    if [ ! -f /etc/arch-release ]; then
        echo -e "${RED}Error: Arch Linux only.${NC}"; exit 1
    fi
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}Error: Do not run as root.${NC}"; exit 1
    fi
    if [ "$AUTO_YES" = false ] && [ "$DRY_RUN" = false ]; then
        echo -e "${YELLOW}Install all packages and symlink all configs? [y/N]${NC}"
        read -r confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
    fi

    echo ""
    sudo pacman -Syu --noconfirm
    echo ""
    install_official
    echo ""
    install_paru
    echo ""
    install_aur
    echo ""
    enable_services
    echo ""
    set_shell
    echo ""
    stow_all "$DOTFILES_DIR"

    echo -e "\n${GREEN}${BOLD}Done! Run ./setup.sh to pick a theme and customize further.${NC}\n"
fi
