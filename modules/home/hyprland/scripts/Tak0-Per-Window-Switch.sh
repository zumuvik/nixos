#!/usr/bin/env bash
set -euo pipefail
##################################################################
#                                                                #   
#                                                                #
#                  TAK_0'S Per-Window-Switch                     #
#                                                                #
#                                                                #
#                                                                #
#  Just a little script that I made to switch keyboard layouts   #
#       per-window instead of global switching for the more      #
#                 smooth and comfortable workflow.               #  
#                                                                #
##################################################################
# This is for changing kb_layouts. Set kb_layouts in Hyprland config

# Validate dependencies
if ! command -v hyprctl &>/dev/null; then
  echo "Error: hyprctl not found. Is Hyprland installed?" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq not found. Please install jq." >&2
  exit 1
fi

if ! command -v socat &>/dev/null; then
  echo "Error: socat not found. Please install socat." >&2
  exit 1
fi

MAP_FILE="${HOME}/.cache/kb_layout_per_window"
CFG_FILE="${HOME}/.config/hypr/configs/SystemSettings.conf"
ICON="${HOME}/.config/swaync/images/ja.png"
SCRIPT_NAME="$(basename "$0")"

# Ensure map file exists
touch "$MAP_FILE" || exit 1

# Read layouts from config
if ! grep -q 'kb_layout' "$CFG_FILE"; then
  echo "Error: cannot find kb_layout in $CFG_FILE" >&2
  exit 1
fi

kb_layouts=($(grep 'kb_layout' "$CFG_FILE" | cut -d '=' -f2 | tr -d '[:space:]' | tr ',' ' '))
count=${#kb_layouts[@]}

if ((count == 0)); then
  echo "Error: no keyboard layouts found in config" >&2
  exit 1
fi

# Get current active window ID
get_win() {
  hyprctl activewindow -j 2>/dev/null | jq -r '.address // .id' || echo ""
}

# Get available keyboards
get_keyboards() {
  hyprctl devices -j 2>/dev/null | jq -r '.keyboards[].name' || return 1
}

# Save window-specific layout
save_map() {
  local W=$1 L=$2
  grep -v "^${W}:" "$MAP_FILE" > "$MAP_FILE.tmp" 2>/dev/null || true
  echo "${W}:${L}" >> "$MAP_FILE.tmp"
  mv -f "$MAP_FILE.tmp" "$MAP_FILE"
}

# Load layout for window (fallback to default)
load_map() {
  local W=$1
  local E
  E=$(grep "^${W}:" "$MAP_FILE" 2>/dev/null || true)
  [[ -n "$E" ]] && echo "${E#*:}" || echo "${kb_layouts[0]}"
}

# Switch layout for all keyboards to layout index
do_switch() {
  local IDX=$1
  local kb
  for kb in $(get_keyboards); do
    hyprctl switchxkblayout "$kb" "$IDX" 2>/dev/null || true
  done
}

# Toggle layout for current window only
cmd_toggle() {
  local W
  W=$(get_win)
  [[ -z "$W" ]] && return
  
  local CUR i NEXT
  CUR=$(load_map "$W")
  
  for idx in "${!kb_layouts[@]}"; do
    if [[ "${kb_layouts[idx]}" == "$CUR" ]]; then
      i=$idx
      break
    fi
  done
  
  NEXT=$(( (i+1) % count ))
  do_switch "$NEXT"
  save_map "$W" "${kb_layouts[NEXT]}"
  notify-send -u low -i "$ICON" "kb_layout: ${kb_layouts[NEXT]}" || true
}

# Restore layout on focus
cmd_restore() {
  local W LAY idx
  W=$(get_win)
  [[ -z "$W" ]] && return
  
  LAY=$(load_map "$W")
  for idx in "${!kb_layouts[@]}"; do
    if [[ "${kb_layouts[idx]}" == "$LAY" ]]; then
      do_switch "$idx"
      break
    fi
  done
}

# Listen to focus events and restore window-specific layouts
subscribe() {
  local SOCKET2="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
  
  if [[ ! -S "$SOCKET2" ]]; then
    echo "Error: Hyprland socket not found at $SOCKET2" >&2
    exit 1
  fi

  socat -u UNIX-CONNECT:"$SOCKET2" - 2>/dev/null | while read -r line; do
    [[ "$line" =~ ^activewindow ]] && cmd_restore || true
  done
}

# Ensure only one listener
if ! pgrep -f "$SCRIPT_NAME.*--listener" >/dev/null 2>&1; then
  subscribe --listener &
fi

# CLI
case "${1:-}" in
  toggle|"") cmd_toggle ;;
  *) 
    echo "Usage: $SCRIPT_NAME [toggle]" >&2
    exit 1
    ;;
esac
