#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya refresh processov

SCRIPTSDIR="$HOME/.config/hypr/scripts"
UserScripts="$HOME/.config/hypr/UserScripts"

# Kill running processes
for proc in waybar rofi swaync ags; do
    pidof "$proc" >/dev/null 2>&1 && pkill "$proc"
done

# Reload wallust
killall -SIGUSR2 waybar 2>/dev/null || true
sleep 0.1

# Refresh quickshell
pkill qs 2>/dev/null || true
qs &

# Restart with SIGUSR1
for proc in waybar rofi swaync ags swaybg; do
    pkill -SIGUSR1 "$proc" 2>/dev/null || true
    sleep 0.1
done

# Restart waybar
sleep 0.1
waybar &

# Restore swaync
sleep 0.3
pkill swaync 2>/dev/null || true
swaync >/dev/null 2>&1 &
swaync-client --reload-config 2>/dev/null || true

# Rainbow borders
if [[ -x "${UserScripts}/RainbowBorders.sh" ]]; then
    sleep 1
    "${UserScripts}/RainbowBorders.sh" &
fi
