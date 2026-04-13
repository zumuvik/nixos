#!/usr/bin/env bash
set -euo pipefail
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  #
# This file used on waybar modules sourcing defaults set in $HOME/.config/hypr/UserConfigs/01-UserDefaults.conf

# Define the path to the config file
config_file="${HOME}/.config/hypr/UserConfigs/01-UserDefaults.conf"

# Check if the config file exists
if [[ ! -f "$config_file" ]]; then
    echo "Error: Configuration file not found: $config_file"
    exit 1
fi

# Process the config file in memory, removing the $ and fixing spaces
config_content=$(sed 's/\$//g' "$config_file" | sed 's/ = /=/')

# Source the modified content directly from the variable
# shellcheck disable=SC1090
eval "$config_content" || {
    echo "Error: Failed to source configuration"
    exit 1
}

# Check if $term is set correctly
if [[ -z "${term:-}" ]]; then
    echo "Error: \$term is not set in the configuration file!"
    exit 1
fi

# Execute accordingly based on the passed argument
launch_files() {
    if [[ -z "${files:-}" ]]; then
        notify-send -u low -i "${HOME}/.config/swaync/images/error.png" \
          "Waybar: files" \
          "Set \$files in 01-UserDefaults.conf or install a default file manager." || true
        return 1
    fi
    eval "${files} &"
}

case "${1:-}" in
    --btop)
        "$term" --title btop sh -c 'btop'
        ;;
    --nvtop)
        "$term" --title nvtop sh -c 'nvtop'
        ;;
    --nmtui)
        "$term" nmtui
        ;;
    --term)
        "$term" &
        ;;
    --files)
        launch_files
        ;;
    *)
        echo "Usage: $0 [--btop | --nvtop | --nmtui | --term | --files]"
        echo "--btop       : Open btop in a new term"
        echo "--nvtop      : Open nvtop in a new term"
        echo "--nmtui      : Open nmtui in a new term"
        echo "--term       : Launch a term window"
        echo "--files      : Launch a file manager"
        exit 1
        ;;
esac