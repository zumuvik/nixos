#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya rofi search

config_file="$HOME/.config/hypr/UserConfigs/01-UserDefaults.conf"

# Check dependencies
command -v jq >/dev/null 2>&1 || { notify-send -u critical "Rofi Search" "jq ne nayden" && exit 1; }

# Check config file
[[ -f "$config_file" ]] || { echo "Oshibka: Config fail ne nayden!" && exit 1; }

# Parse config
config_content=$(sed 's/\$//g' "$config_file" | sed 's/ = /=/')
eval "$config_content"

# Check Search_Engine
[[ -n "${Search_Engine:-}" ]] || { echo "Oshibka: Search_Engine ne nayden v config file!" && exit 1; }

# Kill rofi if running
pgrep -x rofi >/dev/null 2>&1 && pkill rofi

# Get user query
rofi_theme="$HOME/.config/rofi/config-search.rasi"
msg='‼️ **prosmotr** ‼️ poishite v brauzere po umolchaniyu'
query=$(printf '' | rofi -dmenu -config "$rofi_theme" -mesg "$msg" 2>/dev/null)

[[ -z "$query" ]] && exit 0

# URL encode and open
encoded_query=$(printf '%s' "$query" | jq -sRr @uri)
xdg-open "${Search_Engine}${encoded_query}" >/dev/null 2>&1 &
