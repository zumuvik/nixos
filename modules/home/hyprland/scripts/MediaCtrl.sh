#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj playerctl

music_icon="$HOME/.config/swaync/icons/music.png"

# Playerctl functions
playerctl() {
    command -v playerctl >/dev/null 2>&1 || { echo "Oshibka: playerctl ne nayden" && exit 1; }
    command playerctl "$@"
}

play_next() {
    playerctl next
    show_music_notification
}

play_previous() {
    playerctl previous
    show_music_notification
}

toggle_play_pause() {
    playerctl play-pause
    sleep 0.1
    show_music_notification
}

stop_playback() {
    playerctl stop
    notify-send -e -u low -i "$music_icon" " Playback:" " Stopped"
}

show_music_notification() {
    local status title artist
    status=$(playerctl status 2>/dev/null || echo "Unknown")
    
    case "$status" in
        "Playing")
            title=$(playerctl metadata title 2>/dev/null || echo "Unknown")
            artist=$(playerctl metadata artist 2>/dev/null || echo "Unknown")
            notify-send -e -u low -i "$music_icon" "Now Playing:" "$title by $artist"
            ;;
        "Paused")
            notify-send -e -u low -i "$music_icon" " Playback:" " Paused"
            ;;
        *)
            notify-send -e -u low -i "$music_icon" " Status:" " $status"
            ;;
    esac
}

# Main
case "${1:-}" in
    "--nxt")   play_next ;;
    "--prv")   play_previous ;;
    "--pause") toggle_play_pause ;;
    "--stop")  stop_playback ;;
    *)
        echo "Ispolzovanie: $0 [--nxt|--prv|--pause|--stop]"
        exit 1
        ;;
esac
