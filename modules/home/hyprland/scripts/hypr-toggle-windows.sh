#!/usr/bin/env bash
set -euo pipefail

# Get all non-minimized windows
NON_MINIMIZED=$(hyprctl clients -j | jq -r '.[] | select(.minimized == false) | .address')

if [ -z "$NON_MINIMIZED" ]; then
  # All windows are minimized, restore them
  hyprctl clients -j | jq -r '.[] | select(.minimized == true) | .address' | while read -r addr; do
    hyprctl dispatch minimize "$addr"
  done
else
  # Minimize all non-minimized windows
  echo "$NON_MINIMIZED" | while read -r addr; do
    hyprctl dispatch minimize "$addr"
  done
fi