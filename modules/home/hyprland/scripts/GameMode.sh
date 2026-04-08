#!/usr/bin/env bash
set -euo pipefail

# Optsimizirovannyj skript dlya GameMode

notif="$HOME/.config/swaync/images/ja.png"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

# Get current animation state
HYPRGAMEMODE=$(hyprctl getoption animations:enabled 2>/dev/null | awk 'NR==1{print $2}')

if [[ "$HYPRGAMEMODE" == "1" ]]; then
    # Enable Game Mode - disable all animations
    hyprctl --batch "
        keyword animations:enabled 0
        keyword decoration:shadow:enabled 0
        keyword decoration:blur:enabled 0
        keyword general:gaps_in 0
        keyword general:gaps_out 0
        keyword general:border_size 1
        keyword decoration:rounding 0" 2>/dev/null || true
    
    hyprctl keyword "windowrule opacity 1 override 1 override 1 override, ^(.*)$" 2>/dev/null || true
    swww kill 2>/dev/null || true
    notify-send -e -u low -i "$notif" "GameMode" "Vklyucheno"
    exit 0
else
    # Disable Game Mode - restore animations
    swww-daemon --format xrgb 2>/dev/null || true
    [[ -f "$HOME/.config/rofi/.current_wallpaper" ]] && \
        swww img "$HOME/.config/rofi/.current_wallpaper" 2>/dev/null || true
    
    "$SCRIPTSDIR/WallustSwww.sh" 2>/dev/null || true
    sleep 0.5
    hyprctl reload 2>/dev/null || true
    "$SCRIPTSDIR/Refresh.sh" 2>/dev/null || true
    notify-send -e -u normal -i "$notif" "GameMode" "Vklyucheno"
    exit 0
fi
