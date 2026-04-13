#!/usr/bin/env bash
set -euo pipefail

# ClipManager - manager khipy so vsem istoriy

ROFI_THEME="$HOME/.config/rofi/config-clipboard.rasi"
ROFI_MSG="👀 **prosmotr**  CTRL DEL = del zapis | ALT DEL = wipe vse"

# Kill rofi esli raboтаet
pgrep -x rofi >/dev/null 2>&1 && pkill rofi

# Main loop
RESULT=$(rofi -i -dmenu \
    -kb-custom-1 "Control-Delete" \
    -kb-custom-2 "Alt-Delete" \
    -config "$ROFI_THEME" \
    -mesg "$ROFI_MSG" < <(cliphist list) 2>/dev/null)

case "$?" in
    1)  exit 0 ;;
    0)  
        [[ -z "$RESULT" ]] && exit 0
        cliphist decode <<< "$RESULT" | wl-copy
        ;;
    10) cliphist delete <<< "$RESULT" ;;
    11) cliphist wipe ;;
    *)  exit 0 ;;
esac
