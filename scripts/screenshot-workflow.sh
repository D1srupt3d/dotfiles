#!/bin/bash
# Screenshot workflow: capture -> edit -> save
# Usage: screenshot-workflow.sh [region|fullscreen]

MODE=${1:-region}
SCREENSHOT_DIR=~/Pictures/Screenshots
mkdir -p "$SCREENSHOT_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="$SCREENSHOT_DIR/screenshot_$TIMESTAMP.png"

if [ "$MODE" = "region" ]; then
    hyprshot -m region -o "$SCREENSHOT_DIR" -f "screenshot_$TIMESTAMP.png"
else
    hyprshot -m output -m eDP-1 -o "$SCREENSHOT_DIR" -f "screenshot_$TIMESTAMP.png"
fi

# Open in swappy for editing if available
if command -v swappy &>/dev/null && [ -f "$FILENAME" ]; then
    swappy -f "$FILENAME"
fi

notify-send "Screenshot saved" "$FILENAME"
