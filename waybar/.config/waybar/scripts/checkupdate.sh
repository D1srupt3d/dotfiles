#!/bin/bash
# Check for available updates on Arch Linux

# Count updates from official repos
updates=$(checkupdates 2>/dev/null | wc -l)

# Count AUR updates if yay is installed
if command -v yay &> /dev/null; then
    aur_updates=$(yay -Qua 2>/dev/null | wc -l)
    total=$((updates + aur_updates))
else
    total=$updates
fi

# Output the count
if [ "$total" -gt 0 ]; then
    echo "$total"
else
    echo "0"
fi

