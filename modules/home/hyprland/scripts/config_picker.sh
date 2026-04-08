#!/usr/bin/env bash
set -euo pipefail
# Config file picker for Hyprland

CONF_DIR="${HOME}/.config/hypr"

# Validate dependencies
if ! command -v rofi &>/dev/null; then
  notify-send -u critical "Error" "rofi not found. Please install rofi."
  exit 1
fi

TERM_BIN="${TERM_BIN:-kitty}"

# Check if rofi is already running
if pidof rofi &>/dev/null; then
  pkill rofi || true
fi

# Validate directory
if [[ ! -d "$CONF_DIR" ]]; then
  notify-send -u critical "Error" "Config directory not found: $CONF_DIR"
  exit 1
fi

# Generate list of only .conf files
CHOICE=$(find "$CONF_DIR" -maxdepth 1 -name "*.conf" -type f -printf "%f\n" | sort | rofi -dmenu -i -p "Select Config:") || exit 0

# If choice is made
if [[ -n "$CHOICE" ]]; then
    # Try to open with micro or fallback to editor
    if command -v micro &>/dev/null; then
      "$TERM_BIN" micro "$CONF_DIR/$CHOICE"
    elif command -v nano &>/dev/null; then
      "$TERM_BIN" nano "$CONF_DIR/$CHOICE"
    else
      notify-send -u critical "Error" "No text editor found. Install micro or nano."
      exit 1
    fi
fi
