#!/usr/bin/env bash
set -euo pipefail

pgrep -x rofi >/dev/null 2>&1 && pkill rofi

declare -a hints=(
    "super: Super Key (Windows)"
    "super+enter: Terminal (foot)"
    "super+shift+enter: Dropdown Terminal"
    "super+d: Launcher (rofi)"
    "super+e: Files (Thunar)"
    "super+t: Theme picker"
    "super+q: Close window"
    "super+shift+q: Kill window"
    "super+space: Float window"
    "super+w: Wallpaper menu"
    "super+b: Browser default"
    "super+a: Overview (AGS)"
    "super+shift+f: Fullscreen"
    "super+alt+r: Reload services"
    "super+shift+a: Animations"
    "super+shift+g: GameMode toggle"
    "super+alt+e: Emoticons"
    "super+h: KEY HINTS"
)

rofi -dmenu -i -config "$HOME/.config/rofi/config-keyhints.rasi" < <(printf '%s\n' "${hints[@]}")