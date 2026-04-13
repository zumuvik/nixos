#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya skrinshotov

# Peremennye
time=$(date "+%d-%b_%H-%M-%S")
PICTURES_DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"
dir="$PICTURES_DIR/Screenshots"
file="Screenshot_${time}_${RANDOM}.png"

iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

mkdir -p "$dir"

# Vremennaya peremennaya dlya active window
active_class=$(hyprctl -j activewindow 2>/dev/null | jq -r '.class' || echo "unknown")
active_file="Screenshot_${time}_${active_class}.png"
active_path="${dir}/${active_file}"

# FUNKCIYA: otnositelnyj skript
play_sound() {
    if [[ -x "$sDIR/Sounds.sh" ]]; then
        "$sDIR/Sounds.sh" "$1"
    fi
}

# FUNKCIYA: notify i deistviya
notify_view() {
    local check_file="$1"
    local msg_type="$2"
    local title subtitle icon
    
    case "$msg_type" in
        "active")
            [[ -f "$active_path" ]] || { notify-send -u critical "Oshibka" "Skrinshot ne sozdan" && exit 1; }
            title="Skrinshot: ${active_class}"
            subtitle="Sozdan"
            icon="$iDIR/picture.png"
            play_sound "--screenshot"
            ;;
        "swappy")
            [[ -f "$check_file" ]] || { notify-send -u critical "Oshibka" "Skrinshot ne sozdan" && exit 1; }
            title="Skrinshot: Swappy"
            subtitle="Zahвachen"
            icon="$iDIR/picture.png"
            play_sound "--screenshot"
            ;;
        *)
            [[ -f "$check_file" ]] || { notify-send -u critical "Oshibka" "Skrinshot ne sozdan" && exit 1; }
            title="Skrinshot"
            subtitle="Sozdan"
            icon="$iDIR/picture.png"
            play_sound "--screenshot"
            ;;
    esac
    
    # Otnositelnyj notify
    if [[ "$msg_type" == "active" ]]; then
        notify-send -t 10000 \
            -A action1=Open -A action2=Delete \
            -h string:x-canonical-private-synchronous:shot-notify \
            -i "$icon" \
            "$title" "$subtitle" | while read -r resp; do
                case "$resp" in
                    action1) xdg-open "$active_path" &
                    ;;
                    action2) rm -f "$active_path" &
                    ;;
                esac
            done
    elif [[ "$msg_type" == "swappy" ]]; then
        notify-send -t 10000 \
            -A action1=Open -A action2=Delete \
            -h string:x-canonical-private-synchronous:shot-notify \
            -i "$icon" \
            "$title" "$subtitle" | while read -r resp; do
                case "$resp" in
                    action1) swappy -f - < "$check_file" &
                    ;;
                    action2) rm -f "$check_file" &
                    ;;
                esac
            done
    else
        notify-send -t 10000 \
            -A action1=Open -A action2=Delete \
            -h string:x-canonical-private-synchronous:shot-notify \
            -i "$icon" \
            "$title" "$subtitle" | while read -r resp; do
                case "$resp" in
                    action1) xdg-open "$check_file" &
                    ;;
                    action2) rm -f "$check_file" &
                    ;;
                esac
            done
    fi
}

# FUNKCIYA: ozhidanie
countdown() {
    local sec=$1
    for ((i=sec; i>=1; i--)); do
        notify-send -h string:x-canonical-private-synchronous:shot-notify \
            -t 1000 -i "$iDIR/timer.png" \
            "Skrinshot через:" "$i sekund"
        sleep 1
    done
}

# FUNKCIYA: skrinshot now
shot_now() {
    grim - | tee "$dir/$file" | wl-copy
    sleep 2
    notify_view "$dir/$file" "normal"
}

# FUNKCIYA: skrinshot s zaderzhkoi 5 sekund
shot_5() {
    countdown 5
    grim - | tee "$dir/$file" | wl-copy
    sleep 1
    notify_view "$dir/$file" "normal"
}

# FUNKCIYA: skrinshot s zaderzhkoi 10 sekund
shot_10() {
    countdown 10
    sleep 1
    grim - | tee "$dir/$file" | wl-copy
    notify_view "$dir/$file" "normal"
}

# FUNKCIYA: skrinshot aktivnogo okna
shot_window() {
    local pos size
    pos=$(hyprctl activewindow | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
    size=$(hyprctl activewindow | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed 's/,/x/')
    
    grim -g "$pos $size" - | tee "$dir/$file" | wl-copy
    notify_view "$dir/$file" "normal"
}

# FUNKCIYA: skrinshot oblasti
shot_area() {
    local tmpfile
    tmpfile=$(mktemp)
    
    grim -g "$(slurp)" - > "$tmpfile"
    
    if [[ -s "$tmpfile" ]]; then
        wl-copy < "$tmpfile"
        mv "$tmpfile" "$dir/$file"
        notify_view "$dir/$file" "normal"
    else
        notify-send -u low "Oshibka" "Oblast ne vybrana"
        rm -f "$tmpfile"
        exit 1
    fi
}

# FUNKCIYA: skrinshot aktivnogo okna (sozdanii faila)
shot_active() {
    if ! hyprctl -j activewindow >/dev/null 2>&1; then
        notify-send -u critical "Oshibka" "Ne udaetsyaPOLUCHIT active window"
        exit 1
    fi
    
    local window_rect
    window_rect=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    grim -g "$window_rect" - "$active_path"
    
    sleep 1
    notify_view "$active_path" "active"
}

# FUNKCIYA: skrinshot s redaktirovaniem (swappy)
shot_swappy() {
    local tmpfile
    tmpfile=$(mktemp)
    
    grim -g "$(slurp)" - > "$tmpfile"
    
    if [[ -s "$tmpfile" ]]; then
        wl-copy < "$tmpfile"
        notify_view "$tmpfile" "swappy"
    else
        notify-send -u critical "Oshibka" "Oblast ne vybrana"
        exit 1
    fi
}

# MAIN
case "${1:-}" in
    "--now")    shot_now ;;
    "--in5")    shot_5 ;;
    "--in10")   shot_10 ;;
    "--win")    shot_window ;;
    "--area")   shot_area ;;
    "--active") shot_active ;;
    "--swappy") shot_swappy ;;
    *)
        echo "Ispolzovanie: $0 [--now|--in5|--in10|--win|--area|--active|--swappy]"
        exit 1
        ;;
esac

exit 0
