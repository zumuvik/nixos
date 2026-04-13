#!/usr/bin/env bash
set -euo pipefail

# Optsimizirovannyj skript dlya hyprsunset (no4noj podsvetki)

STATE_FILE="$HOME/.cache/.hyprsunset_state"
TARGET_TEMP="${HYPRSUNSET_TEMP:-4500}"

# Obezpechivaem fail sostoyaniya
[[ -f "$STATE_FILE" ]] || echo "off" > "$STATE_FILE"

# Otnositelnye ikonki
icon_off() {
    printf "☀"
}

icon_on() {
    case "${HYPRSUNSET_ICON_MODE:-sunset}" in
        sunset)  printf "🌇" ;;
        blue)    printf "☀" ;;
        *)       printf "☀" ;;
    esac
}

# Pereklyuchenie
cmd_toggle() {
    local state
    state=$(cat "$STATE_FILE")
    
    # Ostanavlivаем vse uslugi hyprsunset
    pgrep -x hyprsunset >/dev/null 2>&1 && {
        pkill -x hyprsunset || true
        sleep 0.3
    }
    
    if [[ "$state" == "on" ]]; then
        # Vyklyuchit
        command -v hyprsunset >/dev/null 2>&1 && {
            nohup hyprsunset -i >/dev/null 2>&1 &
            sleep 0.2 && pkill -x hyprsunset || true
        }
        echo "off" > "$STATE_FILE"
        notify-send -u low "Hyprsunset: Vyklyucheno"
    else
        # Vklyuchit
        command -v hyprsunset >/dev/null 2>&1 && {
            nohup hyprsunset -t "$TARGET_TEMP" >/dev/null 2>&1 &
        }
        echo "on" > "$STATE_FILE"
        notify-send -u low "Hyprsunset: Vklyucheno" "${TARGET_TEMP}K"
    fi
}

# Status dlya Waybar
cmd_status() {
    local state
    state=$(cat "$STATE_FILE")
    
    # Live provodka prossesa
    pgrep -x hyprsunset >/dev/null 2>&1 && state="on"
    
    if [[ "$state" == "on" ]]; then
        local txt icon
        icon=$(icon_on)
        txt="<span size='18pt'>$icon</span>"
        printf '{"text":"%s","class":"on","tooltip":"No4noj podsvetka @ %sK"}\n' "$txt" "$TARGET_TEMP"
    else
        local txt icon
        icon=$(icon_off)
        txt="<span size='16pt'>$icon</span>"
        printf '{"text":"%s","class":"off","tooltip":"No4noj podsvetka vyklyuchena"}\n' "$txt"
    fi
}

# Inicializaciya pri zapuske
cmd_init() {
    local state
    state=$(cat "$STATE_FILE")
    
    if [[ "$state" == "on" ]]; then
        command -v hyprsunset >/dev/null 2>&1 && {
            nohup hyprsunset -t "$TARGET_TEMP" >/dev/null 2>&1 &
        }
    fi
}

# Dispath main
case "${1:-}" in
    toggle) cmd_toggle ;;
    status) cmd_status ;;
    init)   cmd_init ;;
    *)
        echo "Ispolzovanie: $0 [toggle|status|init]"
        exit 2
        ;;
esac
