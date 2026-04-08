#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya keybinds parser

# Kill processes
pkill -q yad 2>/dev/null || true
pgrep -x rofi >/dev/null 2>&1 && pkill rofi

# Define config files
keybinds_conf="$HOME/.config/hypr/configs/Keybinds.conf"
user_keybinds_conf="$HOME/.config/hypr/UserConfigs/UserKeybinds.conf"
laptop_conf="$HOME/.config/hypr/UserConfigs/Laptops.conf"

# Check if config files exist and add them
files=()
[[ -f "$keybinds_conf" ]] && files+=("$keybinds_conf")
[[ -f "$user_keybinds_conf" ]] && files+=("$user_keybinds_conf")
[[ -f "$laptop_conf" ]] && files+=("$laptop_conf")

[[ ${#files[@]} -eq 0 ]] && { echo "Oshibka: Config files ne naydeny" && exit 1; }

# Parse and display keybinds
display_keybinds=$("$HOME/.config/hypr/scripts/keybinds_parser.py" "${files[@]}")

# Check for suggestions file
if [[ -f "/tmp/hypr_keybind_suggestions_file" ]]; then
    suggestions_file=$(cat "/tmp/hypr_keybind_suggestions_file")
    rm -f "/tmp/hypr_keybind_suggestions_file"
    if [[ -n "$suggestions_file" && -f "$suggestions_file" ]]; then
        count=$(wc -l < "$suggestions_file")
        msg="$msg | Overrides missing unbind: $count"
    fi
fi

# Display in rofi
rofi_theme="$HOME/.config/rofi/config-keybinds.rasi"
msg='☣️ **prosmotr** ☣️: Klik i Enter NET'

printf '%s\n' "$display_keybinds" | rofi -dmenu -i -config "$rofi_theme" -mesg "$msg"
