#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj wlogout

# Set parameters for different resolutions
declare -A RES_PARAMS
RES_PARAMS=([2160]=600 [1600]=400 [1440]=400 [1080]=200 [720]=50)

# Check if wlogout is already running
pgrep -x wlogout >/dev/null 2>&1 && { pkill -x wlogout; exit 0; }

# Get monitor info
MONITOR_INFO=$(hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.focused==true) | "\(.height) \(.scale)"')

[[ -z "$MONITOR_INFO" ]] && { echo "Oshibka: ne udaetsya poluchit info monitora" && exit 1; }

read -r height scale <<< "$MONITOR_INFO"
resolution=$(echo "$height / $scale" | bc | cut -d. -f1)

# Set parameters
if [[ "$resolution" -ge 2160 ]]; then
    T_val=${RES_PARAMS[2160]}
    B_val=${RES_PARAMS[2160]}
elif [[ "$resolution" -ge 1600 ]]; then
    T_val=${RES_PARAMS[1600]}
    B_val=${RES_PARAMS[1600]}
elif [[ "$resolution" -ge 1440 ]]; then
    T_val=${RES_PARAMS[1440]}
    B_val=${RES_PARAMS[1440]}
elif [[ "$resolution" -ge 1080 ]]; then
    T_val=${RES_PARAMS[1080]}
    B_val=${RES_PARAMS[1080]}
elif [[ "$resolution" -ge 720 ]]; then
    T_val=${RES_PARAMS[720]}
    B_val=${RES_PARAMS[720]}
    b_val=3
else
    T_val=100
    B_val=100
    b_val=6
fi

# Calculate adjusted values
hypr_scale=$(echo "$scale" | tr -d '"')
T_adj=$(awk "BEGIN {printf \"%.0f\", $T_val * 2160 * $hypr_scale / $resolution}")
B_adj=$(awk "BEGIN {printf \"%.0f\", $B_val * 2160 * $hypr_scale / $resolution}")

# Launch wlogout
if [[ -n "${b_val:-}" && "${b_val}" == "3" ]]; then
    wlogout --protocol layer-shell -b 3 -T "$T_adj" -B "$B_adj" &
else
    wlogout --protocol layer-shell -b 6 -T "$T_adj" -B "$B_adj" &
fi
