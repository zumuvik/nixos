#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="/tmp/hypr-windows-hidden"

# Get all windows
WINDOWS=$(hyprctl clients -j | jq -r '.[] | .address')

if [ -f "$STATE_FILE" ]; then
    # Restore windows from workspace 10
    while read -r addr; do
        hyprctl dispatch movetoworkspace "1,$addr" 2>/dev/null || true
    done <<< "$(cat "$STATE_FILE")"
    rm "$STATE_FILE"
else
    # Save window addresses and move to workspace 10
    echo "$WINDOWS" > "$STATE_FILE"
    for addr in $WINDOWS; do
        hyprctl dispatch movetoworkspace "10,$addr" 2>/dev/null || true
    done
fi