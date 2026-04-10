#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="/tmp/hypr_windows_state"

if [ -f "$STATE_FILE" ]; then
  # Restore windows
  while IFS=: read -r addr ws; do
    hyprctl dispatch movetoworkspace "$ws,$addr"
  done < "$STATE_FILE"
  rm "$STATE_FILE"
else
  # Hide windows to workspace 99
  hyprctl clients -j | jq -r '.[] | select(.hidden == false) | "\(.address):\(.workspace.id)"' | while IFS=: read -r addr ws; do
    echo "$addr:$ws" >> "$STATE_FILE"
    hyprctl dispatch movetoworkspace "99,$addr"
  done
fi