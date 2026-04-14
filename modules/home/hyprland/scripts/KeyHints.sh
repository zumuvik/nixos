#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya keyhints

# Set backend
BACKEND="${GDK_BACKEND:-wayland}"

# Kill conflicting processes
pgrep -x rofi >/dev/null 2>&1 && pkill rofi
pgrep -x yad >/dev/null 2>&1 && pkill yad

# Launch yad
GDK_BACKEND="$BACKEND" yad \
    --center \
    --title="ZUMUVIK" \
    --no-buttons \
    --list \
    --column=Key: \
    --column=Description: \
    --column=Command: \
    --timeout-indicator=bottom \
    "ESC" "close this app" "" \
    "super" "Super Key" "(Windows Key)" \
    "super+enter" "Terminal" "kitty" \
    "super+shift+enter" "Dropdown Terminal" "super+q to close" \
    "super+b" "Browser" "Default" \
    "super+a" "Overview" "AGS" \
    "super+d" "Launcher" "rofi" \
    "super+e" "Files" "Thunar" \
    "super+s" "Search" "rofi" \
    "super+t" "Theme" "rofi" \
    "super+q" "Close" "not kill" \
    "super+shift+q" "Kill" "" \
    "super+alt+scroll" "Zoom" "DesktopMagnifier" \
    "super+alt+v" "Clipboard" "cliphist" \
    "super+w" "Wallpaper" "Menu" \
    "super+shift+w" "Effects" "awww" \
    "super+ctrl+b" "Waybar style" "" \
    "super+alt+b" "Waybar layout" "" \
    "super+alt+r" "Reload" "waybar,rofi,swaync" \
    "super+~" "Notifications" "swaync" \
    "print" "Screenshot" "grim" \
    "super+print" "Area" "grim+slurp" \
    "super+shift+s" "Swappy" "" \
    "super+ctrl+print" "Timer 5s" "" \
    "super+ctrl+shift+print" "Timer 10s" "" \
    "alt+print" "Window" "" \
    "super+shift+f" "Fullscreen" "" \
    "super+ctrl+f" "Fake Fullscreen" "" \
    "super+alt+l" "Layout" "Toggle" \
    "super+space" "Float" "Single" \
    "super+alt+space" "Float All" "" \
    "super+alt+o" "Blur" "Toggle" \
    "super+ctrl+o" "Opaque" "Toggle" \
    "super+shift+a" "Animations" "rofi" \
    "super+ctrl+r" "Rofi Themes" "rofi" \
    "super+shift+g" "Gamemode" "Toggle" \
    "super+alt+e" "Emoticons" "rofi" \
    "super+h" "Cheat Sheet" "this"
