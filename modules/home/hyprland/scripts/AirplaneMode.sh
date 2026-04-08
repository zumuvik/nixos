#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya airplane mode

notif="$HOME/.config/swaync/images/ja.png"

# Check wifi status
if rfkill list wifi | grep -q "Soft blocked: yes"; then
    rfkill unblock wifi
    notify-send -u low -i "$notif" "Airplane" " mode: OFF"
else
    rfkill block wifi
    notify-send -u low -i "$notif" "Airplane" " mode: ON"
fi
