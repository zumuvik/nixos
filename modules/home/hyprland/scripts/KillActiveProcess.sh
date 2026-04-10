#!/usr/bin/env bash
set -euo pipefail
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Kill active window process

# Validate dependencies
if ! command -v hyprctl &>/dev/null; then
  notify-send -u critical "Error" "hyprctl not found. Is Hyprland installed?"
  exit 1
fi

# Get id of an active window
active_pid=$(hyprctl activewindow 2>/dev/null | grep -oP 'pid: \K[0-9]+' || true)

if [[ -z "$active_pid" || ! "$active_pid" =~ ^[0-9]+$ ]]; then
  notify-send -u low -i "${HOME}/.config/swaync/images/error.png" "Kill Active Window" "No active window PID found."
  exit 1
fi

# Close active window
if kill "$active_pid" 2>/dev/null; then
  notify-send -u low "Kill Active Window" "Process $active_pid terminated."
else
  notify-send -u critical "Kill Active Window" "Failed to kill process $active_pid."
  exit 1
fi
