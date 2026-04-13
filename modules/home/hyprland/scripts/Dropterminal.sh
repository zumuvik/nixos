#!/usr/bin/env bash
set -euo pipefail

# Optsimizirovannyj skript dlya dropterminal s animatsiyami

DEBUG=false
ADDR_FILE="/tmp/dropdown_terminal_addr"
SPECIAL_WS="special:scratchpad"

# Configuratsiya
WIDTH_PERCENT=65
HEIGHT_PERCENT=65
Y_PERCENT=10
ANIMATION_STEPS=5
ANIMATION_DELAY=5  # ms

# Parse arguments
if [[ "$1" == "-d" ]]; then
    DEBUG=true
    shift
fi

TERMINAL_CMD="$1"
[[ -z "$TERMINAL_CMD" ]] && { echo "Ispolzovanie: $0 [-d] <terminal>" && exit 1; }

debug() {
    [[ "$DEBUG" == "true" ]] && echo "$*" >&2
}

# Get monitor geometry
get_monitor_info() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x) \(.y) \(.width) \(.height) \(.scale) \(.name)"'
}

# Get focused monitor info
MONITOR_INFO=$(get_monitor_info) || { debug "Error getting monitor info" && exit 1; }
read -r MON_X MON_Y MON_W MON_H MON_SCALE MON_NAME <<< "$MONITOR_INFO"

# Logical calc
MON_W_LOG=$((MON_W / MON_SCALE))
MON_H_LOG=$((MON_H / MON_SCALE))
WIN_W=$((MON_W_LOG * WIDTH_PERCENT / 100))
WIN_H=$((MON_H_LOG * HEIGHT_PERCENT / 100))
WIN_Y=$((MON_Y + MON_H_LOG * Y_PERCENT / 100))
WIN_X=$((MON_X + (MON_W_LOG - WIN_W) / 2))

debug "Monitor: $MON_NAME ($MON_W_LOGx$MON_H_LOG logical)"
debug "Window: ${WIN_W}x${WIN_H} at $WIN_X,$WIN_Y"

# Get window geometry
get_window_geometry() {
    hyprctl clients -j | jq -r --arg ADDR "$1" '.[] | select(.address == $ADDR) | "\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"'
}

# Animate slide down
animate_down() {
    local addr=$1
    local tx=$2 ty=$3 w=$4 h=$5
    local sy=$((ty - h - 50))
    local step_y=$(( (ty - sy) / ANIMATION_STEPS ))
    
    hyprctl dispatch movewindowpixel "exact $tx $sy,address:$addr" >/dev/null 2>&1 || true
    sleep 0.05
    
    for ((i=1; i<=ANIMATION_STEPS; i++)); do
        local cy=$((sy + step_y * i))
        hyprctl dispatch movewindowpixel "exact $tx $cy,address:$addr" >/dev/null 2>&1 || true
        sleep 0.03
    done
    hyprctl dispatch movewindowpixel "exact $tx $ty,address:$addr" >/dev/null 2>&1 || true
}

# Get current workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

# Spawn terminal
spawn() {
    debug "Spawning terminal: $TERMINAL_CMD"
    
    local windows_before windows_after new_addr
    
    windows_before=$(hyprctl clients -j | jq 'length')
    hyprctl dispatch exec "[float; size $WIN_W $WIN_H; workspace special:scratchpad silent] $TERMINAL_CMD" >/dev/null 2>&1
    
    sleep 0.1
    windows_after=$(hyprctl clients -j | jq 'length')
    
    # Get new address
    if [[ "$windows_after" -gt "$windows_before" ]]; then
        new_addr=$(comm -13 \
            <(hyprctl clients -j | jq -r '.[].address' | sort) \
            <(hyprctl clients -j | jq -r '.[].address' | sort) |
            head -1)
    fi
    
    # Fallback
    [[ -z "$new_addr" || "$new_addr" == "null" ]] && \
        new_addr=$(hyprctl clients -j | jq -r 'sort_by(.focusHistoryID) | .[-1] | .address')
    
    if [[ -n "$new_addr" && "$new_addr" != "null" ]]; then
        echo "$new_addr $MON_NAME" > "$ADDR_FILE"
        debug "Terminal address: $new_addr"
        
        sleep 0.2
        hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$new_addr" >/dev/null 2>&1 || true
        hyprctl dispatch pin "address:$new_addr" >/dev/null 2>&1 || true
        animate_down "$new_addr" "$WIN_X" "$WIN_Y" "$WIN_W" "$WIN_H"
        
        return 0
    fi
    
    debug "Failed to spawn terminal"
    return 1
}

# Main logic
get_addr() {
    [[ -f "$ADDR_FILE" ]] && cut -d' ' -f1 "$ADDR_FILE" || echo ""
}

get_monitor() {
    [[ -f "$ADDR_FILE" ]] && cut -d' ' -f2 "$ADDR_FILE" || echo ""
}

terminal_exists() {
    local addr=$(get_addr)
    [[ -n "$addr" ]] && hyprctl clients -j | jq -e --arg A "$addr" '.[] | select(.address == $A)' >/dev/null 2>&1
}

terminal_in_special() {
    local addr=$(get_addr)
    [[ -n "$addr" ]] && hyprctl clients -j | jq -e --arg A "$addr" '.[] | select(.address == $A and .workspace.name == "special:scratchpad")' >/dev/null 2>&1
}

if terminal_exists; then
    TERMINAL_ADDR=$(get_addr)
    FOCUSED_MON=$(get_monitor_info | awk '{print $6}')
    DROPPED_MON=$(get_monitor)
    
    if [[ "$FOCUSED_MON" != "$DROPPED_MON" ]]; then
        debug "Monitor changed, updating position"
        hyprctl dispatch movewindowpixel "exact $WIN_X $WIN_Y,address:$TERMINAL_ADDR" >/dev/null 2>&1 || true
        hyprctl dispatch resizewindowpixel "exact $WIN_W $WIN_H,address:$TERMINAL_ADDR" >/dev/null 2>&1 || true
        echo "$TERMINAL_ADDR $FOCUSED_MON" > "$ADDR_FILE"
    fi
    
    if terminal_in_special; then
        debug "Bringing from scratchpad"
        hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$TERMINAL_ADDR" >/dev/null 2>&1 || true
        hyprctl dispatch resizewindowpixel "exact $WIN_W $WIN_H,address:$TERMINAL_ADDR" >/dev/null 2>&1 || true
        hyprctl dispatch pin "address:$TERMINAL_ADDR" >/dev/null 2>&1 || true
        animate_down "$TERMINAL_ADDR" "$WIN_X" "$WIN_Y" "$WIN_W" "$WIN_H"
        hyprctl dispatch focuswindow "address:$TERMINAL_ADDR" >/dev/null 2>&1 || true
    else
        debug "Hiding to scratchpad"
        # Get geometry
        IFS=' ' read -r cx cy cw ch <<< "$(get_window_geometry "$TERMINAL_ADDR")" || { debug "Failed to get geometry" && exit 1; }
        
        # Calculate end position for animation
        local end_y=$((cy - ch - 50))
        
        # Animate up
        local step_y=$(( (cy - end_y) / ANIMATION_STEPS ))
        for ((i=1; i<=ANIMATION_STEPS; i++)); do
            local cy_up=$((cy - (step_y * i)))
            hyprctl dispatch movewindowpixel "exact $cx $cy_up,address:$TERMINAL_ADDR" >/dev/null 2>&1 || true
            sleep 0.03
        done
        
        hyprctl dispatch pin "address:$TERMINAL_ADDR" >/dev/null 2>&1 || true
        hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$TERMINAL_ADDR" >/dev/null 2>&1 || true
    fi
else
    debug "Spawning new terminal"
    if spawn; then
        hyprctl dispatch focuswindow "address:$(get_addr)" >/dev/null 2>&1 || true
    fi
fi
