#!/usr/bin/env bash
set -euo pipefail

# Get all non-hidden windows
NON_HIDDEN=$(hyprctl clients -j | jq -r '.[] | select(.hidden == false) | .address')

if [ -z "$NON_HIDDEN" ]; then
  # All windows are hidden, restore them
  hyprctl clients -j | jq -r '.[] | select(.hidden == true) | .address' | while read -r addr; do
    hyprctl dispatch minimize "$addr"
  done
else
  # Minimize all non-hidden windows
  echo "$NON_HIDDEN" | while read -r addr; do
    hyprctl dispatch minimize "$addr"
  done
fi