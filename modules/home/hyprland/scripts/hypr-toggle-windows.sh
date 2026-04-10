#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="/tmp/hypr_windows_state"

if [ -f "$STATE_FILE" ]; then
  # Restore windows from ws 99 back to their original workspaces
  while IFS=: read -r addr ws; do
    hyprctl dispatch movetoworkspace "$addr,$ws"
  done < "$STATE_FILE"
  rm "$STATE_FILE"
else
  # Hide all windows to ws 99 and save current workspace
  hyprctl clients -j | jq -r '.[] | select(.hidden == false) | .address' | while read -r addr; do
    ws=$(hyprctl clients -j | jq -r --arg addr "$addr" '.[] | select(.address == $addr) | .workspace.id')
    echo "$addr:$ws" >> "$STATE_FILE"
    hyprctl dispatch movetoworkspace "$addr,99"
  done
fi
