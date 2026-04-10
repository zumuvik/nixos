#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya zvuka

theme="freedesktop"

# Mute individual sounds
muteScreenshots=false
muteVolume=false

# Exit if muted
if [[ "$muteScreenshots" == true && "$1" == "--screenshot" ]]; then
    exit 0
fi
[[ "$muteVolume" == true && "$1" == "--volume" ]] && exit 0

# Choose sound file
case "$1" in
    "--screenshot") soundoption="screen-capture.*" ;;
    "--volume")     soundoption="audio-volume-change.*" ;;
    "--error")      soundoption="dialog-error.*" ;;
    *)
        echo "Dostupnye zvuki: --screenshot, --volume, --error"
        exit 1
        ;;
esac

# Set sound directory
if [[ -d "/run/current-system/sw/share/sounds" ]]; then
    systemDIR="/run/current-system/sw/share/sounds"
else
    systemDIR="/usr/share/sounds"
fi
userDIR="$HOME/.local/share/sounds"
defaultTheme="freedesktop"

# Find theme directory
sDIR="$systemDIR/$defaultTheme"
[[ -d "$userDIR/$theme" ]] && sDIR="$userDIR/$theme"
[[ -d "$systemDIR/$theme" ]] && sDIR="$systemDIR/$theme"

# Find inherited theme
iTheme=$(grep -i "inherits" "$sDIR/index.theme" 2>/dev/null | cut -d= -f2 | tr -d ' ')
[[ -z "$iTheme" ]] && iTheme="$defaultTheme"
iDIR="$sDIR/../$iTheme"

# Find sound file
sound_file=""
for dir in "$sDIR/stereo" "$iDIR/stereo" "$userDIR/$defaultTheme/stereo" "$systemDIR/$defaultTheme/stereo"; do
    [[ -z "$sound_file" ]] && sound_file=$(find -L "$dir" -name "$soundoption" -print -quit 2>/dev/null || true)
    [[ -f "$sound_file" ]] && break
done

[[ -z "$sound_file" ]] && { echo "Oshibka: Zvukovoj fail ne nayden" && exit 1; }

# Play sound
if command -v pw-play >/dev/null 2>&1; then
    pw-play "$sound_file" 2>/dev/null || exit 1
elif command -v paplay >/dev/null 2>&1; then
    paplay "$sound_file" 2>/dev/null || exit 1
elif command -v aplay >/dev/null 2>&1; then
    aplay "$sound_file" 2>/dev/null || exit 1
else
    echo "Oshibka: Nykyj zvukovoj player (pw-play/paplay/aplay) ne nayden" && exit 1
fi
