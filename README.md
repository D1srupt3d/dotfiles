# Hyprland Dotfiles

A fully themed Hyprland desktop setup for Arch Linux with an interactive setup wizard, 9 color themes, and modular component installation.

## Get Started

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

That's it. The wizard walks you through everything.

---

## What the wizard does

1. **Asks what you want** — fresh install, change theme, or add/remove components
2. **You pick what to install** — only install the parts you want
3. **You pick a color theme** — with a live color preview in the terminal
4. **Shows a summary** — nothing happens until you confirm
5. **Installs and configures** — packages, stow symlinks, services

---

## Themes

| Theme | Style |
|---|---|
| Monochrome | Black, gray and white (default) |
| Catppuccin Mocha | Dark with soft purple and pink |
| Catppuccin Latte | Light version, warm and creamy |
| Nord | Arctic blues and clean slate gray |
| Dracula | Dark purple with pink and cyan |
| Tokyo Night | Deep navy blue with purple glow |
| Gruvbox | Warm retro oranges on dark brown |
| Everforest | Muted greens and earthy tones |

To switch themes at any time, just re-run `./setup.sh` and choose "Change theme".

---

## Components

| Component | What it does |
|---|---|
| Hyprland | The window manager |
| Waybar | Top bar with clock, battery, and system info |
| SwayNC | Notification popups and control center |
| Wofi | App launcher (Super+Space) |
| Wlogout | Power menu (shutdown, reboot, lock) |
| Ghostty | Terminal emulator |
| Zsh + Starship | Shell with a styled prompt |
| Btop | System resource monitor |
| Fastfetch | System info on terminal launch |

---

## Key Bindings

| Keys | Action |
|---|---|
| `Super + Space` | Open app launcher |
| `Super + Enter` | Open terminal |
| `Super + B` | Open Firefox |
| `Super + E` | Open file manager |
| `Super + N` | Toggle notification center |
| `Super + L` | Lock screen |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + T` | Toggle floating |
| `Super + Print` | Region screenshot |
| `Shift + Print` | Full screenshot |
| `Super + [1-9]` | Switch workspace |
| `Super + Ctrl + [1-9]` | Move window to workspace |

---

## Changing Your Wallpaper

1. Add your wallpaper to `wallpapers/`
2. Edit `~/.config/hypr/hyprpaper.conf`

```ini
preload = ~/dotfiles/wallpapers/your-wallpaper.jpg
wallpaper = eDP-1,~/dotfiles/wallpapers/your-wallpaper.jpg
```

3. Reload with `Super + Shift + W`

---

## Advanced

### Non-interactive install (power users)

```bash
./scripts/install.sh --dry-run   # preview what would be installed
./scripts/install.sh --yes       # install everything without prompts
```

### Switch themes from the command line

```bash
./scripts/switch-theme.sh catppuccin-mocha
./scripts/switch-theme.sh --help   # list all themes
```

### Adding a custom theme

```bash
cp themes/monochrome.theme themes/my-theme.theme
# Edit the hex color values in my-theme.theme
./scripts/switch-theme.sh my-theme
```

### Monitor setup

Edit `~/.config/hypr/conf/monitor.conf`:

```ini
monitor = eDP-1, 2560x1600@60, 0x0, 1
monitor = HDMI-A-1, 1920x1080@60, 2560x0, 1
```

---

## Troubleshooting

**Hyprland won't start**
- Check logs: `~/.local/share/hyprland/hyprland.log`
- Make sure your GPU drivers are installed

**Waybar missing**
- Reload: `Super + Shift + B`
- Or manually: `waybar &`

**No sound**
- Check: `systemctl --user status pipewire`
- Start: `systemctl --user start pipewire pipewire-pulse`

**Screenshots not working**
- Install hyprshot: `paru -S hyprshot`

---

## Requirements

- Arch Linux (or Arch-based distro)
- Internet connection
- A user account with sudo access

---

## License

MIT — do whatever you want with it.
