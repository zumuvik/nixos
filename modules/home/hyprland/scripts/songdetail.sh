#!/usr/bin/env bash
set -euo pipefail
# Get current song details from playerctl

# Validate dependency
if ! command -v playerctl &>/dev/null; then
  echo "Error: playerctl not found. Please install playerctl."
  exit 1
fi

# Get song metadata
song_info=$(playerctl metadata --format '{{title}}  {{artist}}' 2>/dev/null || echo "No song playing")

echo "$song_info"
