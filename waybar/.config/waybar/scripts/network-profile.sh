#!/bin/bash
# Output active NetworkManager profile name + bandwidth for Waybar
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
CACHE="$CACHE_DIR/network-bytes"
mkdir -p "$CACHE_DIR"

name=$(nmcli -t -f name connection show --active 2>/dev/null | head -1)
type=$(nmcli -t -f type connection show --active 2>/dev/null | head -1)
device=$(nmcli -t -f device connection show --active 2>/dev/null | head -1)

if [ -z "$name" ]; then
    echo "󰖪 Disconnected"
    exit 0
fi

# Get rx/tx bytes for the active device from /proc/net/dev
# First field in /proc/net/dev is "ifname:", then rx bytes ($2), tx bytes ($10)
get_bytes() {
    local dev="$1"
    [ -z "$dev" ] && return
    awk -v dev="${dev}:" 'NR>2 && $1 == dev { print $2, $10; exit }' /proc/net/dev 2>/dev/null
}

read now_rx now_tx < <(get_bytes "$device")
now=$(date +%s)

if [ -n "$now_rx" ] && [ -f "$CACHE" ]; then
    read prev_dev prev_rx prev_tx prev_ts < "$CACHE"
    if [ "$prev_dev" = "$device" ] && [ -n "$prev_ts" ] && [ "$prev_ts" -lt "$now" ]; then
        interval=$(( now - prev_ts ))
        [ "$interval" -lt 1 ] && interval=1
        rx_rate=$(( (now_rx - prev_rx) / interval ))
        tx_rate=$(( (now_tx - prev_tx) / interval ))
        # Format as Mb/s or Kb/s (bytes -> bits: *8)
        fmt() {
            local bps=$(( $1 * 8 ))
            if [ "$bps" -ge 1048576 ]; then
                echo "$(( bps / 1048576 )).$(( (bps % 1048576) / 104857 ))"Mb
            elif [ "$bps" -ge 1024 ]; then
                echo "$(( bps / 1024 ))"Kb
            else
                echo "${bps}"b
            fi
        }
        down=$(fmt $rx_rate)
        up=$(fmt $tx_rate)
        speeds="  ↓${down}  ↑${up}"
    fi
fi
[ -n "$now_rx" ] && [ -n "$now_tx" ] && echo "$device $now_rx $now_tx $now" > "$CACHE"

case "$type" in
    wifi|802-11-wireless)  icon="󰖩" ;;
    *)                    icon="󰈀" ;;
esac

echo "${icon} ${name}${speeds:-}"
