#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya refresh bez waybar

SCRIPTSDIR="$HOME/.config/hypr/scripts"
UserScripts="$HOME/.config/hypr/UserScripts"

# Kill rofi
pidof rofi >/dev/null 2>&1 && pkill rofi

# Refresh quickshell
pkill qs 2>/dev/null || true
qs &

# Refresh wallust
"$SCRIPTSDIR/WallustSwww.sh" 2>/dev/null || true
sleep 0.2

# Reload swaync
swaync-client --reload-config 2>/dev/null || true

# Rainbow borders
if [[ -x "${UserScripts}/RainbowBorders.sh" ]]; then
    sleep 1
    "${UserScripts}/RainbowBorders.sh" &
fi
