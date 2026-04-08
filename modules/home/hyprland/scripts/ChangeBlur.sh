#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya change blur

notif="$HOME/.config/swaync/images"

STATE=$(hyprctl -j getoption decoration:blur:passes 2>/dev/null | jq '.int' 2>/dev/null || echo "1")

if [[ "${STATE:-1}" == "2" ]]; then
    hyprctl keyword decoration:blur:size 2 2>/dev/null || true
    hyprctl keyword decoration:blur:passes 1 2>/dev/null || true
    notify-send -e -u low -i "$notif/note.png" " Less Blur"
else
    hyprctl keyword decoration:blur:size 5 2>/dev/null || true
    hyprctl keyword decoration:blur:passes 2 2>/dev/null || true
    notify-send -e -u low -i "$notif/ja.png" " Normal Blur"
fi
