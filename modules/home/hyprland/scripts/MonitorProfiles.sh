#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya monitor profiles

# Kill rofi if running
pgrep -x rofi >/dev/null 2>&1 && pkill rofi

# Variables
iDIR="$HOME/.config/swaync/images"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
monitor_dir="$HOME/.config/hypr/Monitor_Profiles"
target="$HOME/.config/hypr/monitors.conf"
rofi_theme="$HOME/.config/rofi/config-Monitors.rasi"
msg='⚠️ **prosmotr** ⚠️: This will overwrite monitors.conf'

# Get list of profiles (exclude README)
mon_profiles_list=$(find -L "$monitor_dir" -maxdepth 1 -type f -name "*.conf" 2>/dev/null | \
    sed 's/.*\///' | sed 's/\.conf$//' | grep -v -E "^README$" | sort -V)

[[ -z "$mon_profiles_list" ]] && { echo "Oshibka:Monitor profiles ne naydeny" && exit 1; }

# Rofi menu
chosen_file=$(echo "$mon_profiles_list" | rofi -i -dmenu -config "$rofi_theme" -mesg "$msg" 2>/dev/null)

if [[ -n "$chosen_file" ]]; then
    full_path="$monitor_dir/$chosen_file.conf"
    [[ -f "$full_path" ]] && cp "$full_path" "$target"
    
    notify-send -u low -i "$iDIR/ja.png" "$chosen_file" "Monitor Profile Loaded"
    
    sleep 1
    "$SCRIPTSDIR/RefreshNoWaybar.sh" &
fi
