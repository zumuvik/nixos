#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya portal hyprland

# Kill all portal processes
pkill -q -x xdg-desktop-portal-hyprland 2>/dev/null || true
pkill -q -x xdg-desktop-portal-wlr 2>/dev/null || true
pkill -q -x xdg-desktop-portal-gnome 2>/dev/null || true
pkill -q -x xdg-desktop-portal 2>/dev/null || true
sleep 1

# Start hyprland portal
hyprland_portal=$(
    for candidate in /usr/lib/xdg-desktop-portal-hyprland /usr/libexec/xdg-desktop-portal-hyprland; do
        [[ -x "$candidate" ]] && echo "$candidate" && break
    done
)

if [[ -z "$hyprland_portal" ]]; then
    echo "Oshibka: xdg-desktop-portal-hyprland ne nayden" >&2
    exit 1
fi

"$hyprland_portal" &
sleep 2

# Start general portal
general_portal=$(
    for candidate in /usr/lib/xdg-desktop-portal /usr/libexec/xdg-desktop-portal; do
        [[ -x "$candidate" ]] && echo "$candidate" && break
    done
)

if [[ -n "$general_portal" ]]; then
    "$general_portal" &
else
    echo "Oshibka: xdg-desktop-portal ne nayden" >&2
    exit 1
fi
