#!/usr/bin/env bash
set -euo pipefail
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For applying Animations from different users

# Kill any existing rofi instance
if pidof rofi &>/dev/null; then
  pkill rofi || true
fi

# Variables
iDIR="${HOME}/.config/swaync/images"
SCRIPTSDIR="${HOME}/.config/hypr/scripts"
animations_dir="${HOME}/.config/hypr/animations"
UserConfigs="${HOME}/.config/hypr/UserConfigs"
rofi_theme="${HOME}/.config/rofi/config-Animations.rasi"
msg='❗NOTE:❗ This will copy animations into UserAnimations.conf'

# Validate directories exist
if [[ ! -d "$animations_dir" ]]; then
  notify-send -u critical -i "${iDIR}/error.png" "Error" "Animations directory not found: $animations_dir"
  exit 1
fi

if [[ ! -d "$UserConfigs" ]]; then
  notify-send -u critical -i "${iDIR}/error.png" "Error" "UserConfigs directory not found: $UserConfigs"
  exit 1
fi

# List animation files, sorted alphabetically with numbers first
animations_list=$(find -L "$animations_dir" -maxdepth 1 -type f | sed 's/.*\///' | sed 's/\.conf$//' | sort -V)

if [[ -z "$animations_list" ]]; then
  notify-send -u critical -i "${iDIR}/error.png" "Error" "No animation files found in $animations_dir"
  exit 1
fi

# Rofi Menu
chosen_file=$(echo "$animations_list" | rofi -i -dmenu -config "$rofi_theme" -mesg "$msg")

# Check if a file was selected
if [[ -n "$chosen_file" ]]; then
    full_path="$animations_dir/$chosen_file.conf"
    
    if [[ ! -f "$full_path" ]]; then
      notify-send -u critical -i "${iDIR}/error.png" "Error" "Animation file not found: $full_path"
      exit 1
    fi
    
    cp "$full_path" "$UserConfigs/UserAnimations.conf"
    notify-send -u low -i "${iDIR}/ja.png" "$chosen_file" "Hyprland Animation Loaded"
    
    sleep 1
    if [[ -x "$SCRIPTSDIR/RefreshNoWaybar.sh" ]]; then
      "$SCRIPTSDIR/RefreshNoWaybar.sh"
    fi
fi
