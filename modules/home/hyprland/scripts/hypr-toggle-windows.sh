#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="/tmp/hypr-windows-visible"

if [ -f "$STATE_FILE" ]; then
    hyprctl dispatch visibility all on
    rm "$STATE_FILE"
else
    hyprctl dispatch visibility all off
    touch "$STATE_FILE"
fi