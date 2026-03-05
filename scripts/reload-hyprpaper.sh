#!/bin/bash
killall hyprpaper 2>/dev/null
sleep 1
# Detach so hyprpaper keeps running after this script (or the terminal) exits
nohup hyprpaper >/dev/null 2>&1 &
disown