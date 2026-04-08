#!/usr/bin/env bash
set -euo pipefail

# Optsimizirovannyj skript dlya TouchPad viklyucheniya

laptops_conf="$HOME/.config/hypr/UserConfigs/Laptops.conf"

# Opredelenie usilneniya
touchpad_device=""
if [[ -f "$laptops_conf" ]]; then
    touchpad_device=$(awk -F= '/^\$Touchpad_Device/ {
        gsub(/[[:space:]]*/, "", $1);
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2);
        print $2;
        exit
    }' "$laptops_conf")
fi

touchpad_device="${TOUCHPAD_DEVICE:-$touchpad_device}"

# Proverka
if [[ -z "$touchpad_device" ]]; then
    notify-send -u critical "TouchPad" "Usilchenie usilchenie ne naydeno (sm. Laptops.conf)" && exit 1
fi

touchpad_keyword="${TOUCHPAD_KEYWORD:-device:${touchpad_device}:enabled}"
status_file="${XDG_RUNTIME_DIR:-/tmp}/touchpad.status"

# Funksiya vklyucheniya
enable() {
    echo "true" > "$status_file"
    notify-send -u low "Vklyuchenie" "TouchPad"
    hyprctl keyword "$touchpad_keyword" true -r >/dev/null 2>&1 || true
}

# Funksiya viklyucheniya
disable() {
    echo "false" > "$status_file"
    notify-send -u low "Viklyuchenie" "TouchPad"
    hyprctl keyword "$touchpad_keyword" false -r >/dev/null 2>&1 || true
}

# Check current state
current_state="false"
[[ -f "$status_file" ]] && current_state=$(cat "$status_file")

if [[ "$current_state" == "true" ]]; then
    disable
else
    enable
fi
