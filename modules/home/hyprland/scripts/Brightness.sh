#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for Monitor backlights using brightnessctl

iDIR="$HOME/.config/swaync/icons"

# Validation
if ! command -v brightnessctl >/dev/null 2>&1; then
    notify-send -u critical "Error" "brightnessctl not found" && exit 1
fi

# Get current brightness percentage
get_brightness() {
    brightnessctl -m | cut -d, -f4 | tr -d '%'
}

# Get appropriate icon based on brightness level
get_icon() {
    local brightness=$1
    local level=$(( (brightness + 19) / 20 * 20 ))
    (( level > 100 )) && level=100
    echo "$iDIR/brightness-${level}.png"
}

# Send notification with brightness value
notify() {
    local brightness=$1
    local icon=$2
    notify-send -e \
        -h string:x-canonical-private-synchronous:brightness_notif \
        -h int:value:"$brightness" \
        -u low -i "$icon" \
        "Screen" "Brightness: ${brightness}%" || true
}

# Get icon path for notification
notify_with_icon() {
    local brightness=$1
    local icon=$2
    notify-send -e \
        -h string:x-canonical-private-synchronous:brightness_notif \
        -h int:value:"$brightness" \
        -u low -i "$icon" \
        "Screen" "Brightness: ${brightness}%" || true
}

# Change brightness by delta
change() {
    local delta=$1
    local current new icon
    
    current=$(get_brightness)
    new=$((current + delta))
    
    # Clamp values
    (( new < 5 )) && new=5
    (( new > 100 )) && new=100
    
    brightnessctl set "${new}%" >/dev/null
    icon=$(get_icon "$new")
    notify_with_icon "$new" "$icon"
}

# Main dispatch
case "${1:-}" in
    "--get")  get_brightness ;;
    "--inc")  change 10 ;;
    "--dec")  change -10 ;;
    *)        get_brightness ;;
esac
