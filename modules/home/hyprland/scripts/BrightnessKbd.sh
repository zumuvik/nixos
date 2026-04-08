#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya Brightnesskbd

iDIR="$HOME/.config/swaync/icons"

# Get keyboard brightness
get_kbd_backlight() {
    brightnessctl -d '*::kbd_backlight' -m 2>/dev/null | cut -d, -f4
}

# Get icon
get_icon() {
    local current
    current=$(get_kbd_backlight | sed 's/%//' || echo "0")
    
    if [[ "$current" -le 20 ]]; then
        echo "$iDIR/brightness-20.png"
    elif [[ "$current" -le 40 ]]; then
        echo "$iDIR/brightness-40.png"
    elif [[ "$current" -le 60 ]]; then
        echo "$iDIR/brightness-60.png"
    elif [[ "$current" -le 80 ]]; then
        echo "$iDIR/brightness-80.png"
    else
        echo "$iDIR/brightness-100.png"
    fi
}

# Notify
notify_user() {
    local current icon
    current=$(get_kbd_backlight | sed 's/%//' || echo "0")
    icon=$(get_icon)
    
    notify-send -e \
        -h string:x-canonical-private-synchronous:brightness_notif \
        -h int:value:"$current" \
        -h boolean:SWAYNC_BYPASS_DND:true \
        -u low \
        -i "$icon" \
        "Keyboard" "Brightness: ${current}%"
}

# Change brightness
change_kbd_backlight() {
    brightnessctl -d '*::kbd_backlight' set "$1" >/dev/null 2>&1 && notify_user
}

# Main
case "${1:-}" in
    "--get")   get_kbd_backlight ;;
    "--inc")   change_kbd_backlight "+30%" ;;
    "--dec")   change_kbd_backlight "30%-" ;;
    *)         get_kbd_backlight ;;
esac
