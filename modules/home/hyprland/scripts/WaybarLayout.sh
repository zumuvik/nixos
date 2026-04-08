#!/usr/bin/env bash
set -euo pipefail
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for waybar layout or configs

IFS=$'\n\t'

# Define directories
waybar_layouts="${HOME}/.config/waybar/configs"
waybar_config="${HOME}/.config/waybar/config"
SCRIPTSDIR="${HOME}/.config/hypr/scripts"
rofi_config="${HOME}/.config/rofi/config-waybar-layout.rasi"
msg=' 🎌 NOTE: Some waybar LAYOUT NOT fully compatible with some STYLES'

# Validate directories exist
if [[ ! -d "$waybar_layouts" ]]; then
  echo "Error: waybar layouts directory not found: $waybar_layouts"
  exit 1
fi

# Apply selected configuration
apply_config() {
    local config_name="$1"
    
    if [[ ! -f "${waybar_layouts}/${config_name}" ]]; then
      echo "Error: Config file not found: ${waybar_layouts}/${config_name}"
      return 1
    fi
    
    ln -sf "${waybar_layouts}/${config_name}" "$waybar_config" || return 1
    
    if [[ -x "${SCRIPTSDIR}/Refresh.sh" ]]; then
      "${SCRIPTSDIR}/Refresh.sh" &
    fi
}

main() {
    # Resolve current symlink target and basename
    local current_target current_name
    
    if [[ -L "$waybar_config" ]]; then
      current_target=$(readlink -f "$waybar_config") || ""
      current_name=$(basename "$current_target") || ""
    else
      current_name=""
    fi

    # Build sorted list of available layouts
    mapfile -t options < <(
        find -L "$waybar_layouts" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null | sort || true
    )

    if [[ ${#options[@]} -eq 0 ]]; then
      echo "Error: No waybar config files found in $waybar_layouts"
      exit 1
    fi

    # Mark and locate the active layout
    local default_row=0
    local MARKER="👉"
    for i in "${!options[@]}"; do
        if [[ "${options[i]}" == "$current_name" ]]; then
            options[i]="$MARKER ${options[i]}"
            default_row=$i
            break
        fi
    done

    # Launch rofi with the annotated list, pre‑selecting the active row
    local choice
    choice=$(printf '%s\n' "${options[@]}" \
        | rofi -i -dmenu \
               -config "$rofi_config" \
               -mesg "$msg" \
               -selected-row "$default_row") || return 0

    # Exit if nothing chosen
    [[ -z "$choice" ]] && { echo "No option selected. Exiting."; exit 0; }

    # Strip marker before applying
    choice=${choice#"$MARKER "}

    case "$choice" in
        "no panel")
            if pgrep -x "waybar" >/dev/null 2>&1; then
              pkill waybar || true
            fi
            ;;
        *)
            apply_config "$choice"
            ;;
    esac
}

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null 2>&1; then
    pkill rofi || true
fi

main
