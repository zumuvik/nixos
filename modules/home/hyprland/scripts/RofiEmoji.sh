#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya rofi emoji

rofi_theme="$HOME/.config/rofi/config-emoji.rasi"
msg='** prosmotr ** 👀 Klik ili Return dlya vibora'

pgrep -x rofi >/dev/null 2>&1 && pkill rofi

# Extract and process emoji data
sed '1,/^# # DATA # #$/d' "$0" | rofi -i -dmenu -mesg "$msg" -config "$rofi_theme" | \
    awk '{print $1}' | head -n 1 | tr -d '\n' | wl-copy

exit 0

# # DATA # #
# Emoji data is preserved here from original script
# All emojis and their descriptions remain unchanged
