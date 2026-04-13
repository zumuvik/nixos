#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya polkit

# Find valid polkit-gnome executable
polkit_gnome_path=$(find /nix/store -name 'polkit-gnome-authentication-agent-1' -type f -executable 2>/dev/null | head -1)

if [[ -n "$polkit_gnome_path" ]]; then
    "$polkit_gnome_path" &
    exit 0
else
    echo "Oshibka: Polkit-GNOME Authentication Agent ne nayden" >&2
    exit 1
fi
