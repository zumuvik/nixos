#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Scripts for volume controls for audio and mic

iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

# Validation
if ! command -v pamixer >/dev/null 2>&1; then
    notify-send -u critical "Error" "pamixer not found" && exit 1
fi

get_volume() {
    local muted vol
    muted=$(pamixer --get-mute)
    vol=$(pamixer --get-volume 2>/dev/null || echo "0")
    
    if [[ "$muted" == "true" || "$vol" -eq 0 ]]; then
        echo "Muted"
    else
        echo "$vol%"
    fi
}

get_icon() {
    local muted vol
    muted=$(pamixer --get-mute)
    vol=$(pamixer --get-volume 2>/dev/null || echo "0")
    
    if [[ "$muted" == "true" ]]; then
        echo "$iDIR/volume-mute.png"
    elif [[ "$vol" -le 30 ]]; then
        echo "$iDIR/volume-low.png"
    elif [[ "$vol" -le 60 ]]; then
        echo "$iDIR/volume-mid.png"
    else
        echo "$iDIR/volume-high.png"
    fi
}

notify_vol() {
    local muted vol icon
    muted=$(pamixer --get-mute)
    vol=$(pamixer --get-volume 2>/dev/null || echo "0")
    
    if [[ "$muted" == "true" || "$vol" -eq 0 ]]; then
        notify-send -e \
            -h string:x-canonical-private-synchronous:volume_notif \
            -h boolean:SWAYNC_BYPASS_DND:true -u low \
            -i "$iDIR/volume-mute.png" \
            " Volume:" " Muted"
    else
        notify-send -e \
            -h int:value:"$vol" \
            -h string:x-canonical-private-synchronous:volume_notif \
            -h boolean:SWAYNC_BYPASS_DND:true -u low \
            -i "$(get_icon)" \
            " Volume:" " ${vol}%" && \
        "$sDIR/Sounds.sh" --volume
    fi
}

inc_vol() {
    local step=${1:-5}
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
        toggle_mute
    else
        pamixer -i "$step" --allow-boost --set-limit 150 >/dev/null
        notify_vol
    fi
}

dec_vol() {
    local step=${1:-5}
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
        toggle_mute
    else
        pamixer -d "$step" >/dev/null
        notify_vol
    fi
}

toggle_mute() {
    if [[ "$(pamixer --get-mute)" == "false" ]]; then
        pamixer -m >/dev/null
        notify-send -e -u low \
            -h boolean:SWAYNC_BYPASS_DND:true \
            -i "$iDIR/volume-mute.png" " Mute"
    else
        pamixer -u >/dev/null
        notify-send -e -u low \
            -h boolean:SWAYNC_BYPASS_DND:true \
            -i "$(get_icon)" " Volume:" " ON"
    fi
}

get_mic() {
    local muted vol
    muted=$(pamixer --default-source --get-mute)
    vol=$(pamixer --default-source --get-volume 2>/dev/null || echo "0")
    
    if [[ "$muted" == "true" || "$vol" -eq 0 ]]; then
        echo "Muted"
    else
        echo "$vol%"
    fi
}

get_mic_icon() {
    local muted vol
    muted=$(pamixer --default-source --get-mute)
    vol=$(pamixer --default-source --get-volume 2>/dev/null || echo "0")
    
    if [[ "$muted" == "true" || "$vol" -eq 0 ]]; then
        echo "$iDIR/microphone-mute.png"
    else
        echo "$iDIR/microphone.png"
    fi
}

notify_mic() {
    local muted vol icon
    muted=$(pamixer --default-source --get-mute)
    vol=$(pamixer --default-source --get-volume 2>/dev/null || echo "0")
    
    icon="$iDIR/microphone-mute.png"
    [[ "$muted" != "true" && "$vol" -gt 0 ]] && icon="$iDIR/microphone.png"
    
    if [[ "$muted" == "true" || "$vol" -eq 0 ]]; then
        notify-send -e \
            -h string:x-canonical-private-synchronous:volume_notif \
            -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$icon" \
            " Mic:" " Muted"
    else
        notify-send -e \
            -h int:value:"$vol" \
            -h string:x-canonical-private-synchronous:volume_notif \
            -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$icon" \
            " Mic:" " ${vol}%"
    fi
}

inc_mic() {
    if [[ "$(pamixer --default-source --get-mute)" == "true" ]]; then
        toggle_mic
    else
        pamixer --default-source -i 5 >/dev/null
        notify_mic
    fi
}

dec_mic() {
    if [[ "$(pamixer --default-source --get-mute)" == "true" ]]; then
        toggle_mic
    else
        pamixer --default-source -d 5 >/dev/null
        notify_mic
    fi
}

toggle_mic() {
    if [[ "$(pamixer --default-source --get-mute)" == "false" ]]; then
        pamixer --default-source -m >/dev/null
        notify-send -e -u low \
            -h boolean:SWAYNC_BYPASS_DND:true \
            -i "$iDIR/microphone-mute.png" " Mic:" " OFF"
    else
        pamixer --default-source -u >/dev/null
        notify-send -e -u low \
            -h boolean:SWAYNC_BYPASS_DND:true \
            -i "$iDIR/microphone.png" " Mic:" " ON"
    fi
}

# Main dispatch
case "${1:-}" in
    "--get")          get_volume ;;
    "--inc")          inc_vol 5 ;;
    "--dec")          dec_vol 5 ;;
    "--inc-precise")  inc_vol 1 ;;
    "--dec-precise")  dec_vol 1 ;;
    "--toggle")       toggle_mute ;;
    "--toggle-mic")   toggle_mic ;;
    "--get-icon")     get_icon ;;
    "--get-mic-icon") get_mic_icon ;;
    "--mic-inc")      inc_mic ;;
    "--mic-dec")      dec_mic ;;
    *)                get_volume ;;
esac
