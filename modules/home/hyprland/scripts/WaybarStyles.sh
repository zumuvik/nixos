#!/usr/bin/env bash
set -euo pipefail
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for waybar styles

IFS=$'\n\t'

# Define directories
waybar_styles="${HOME}/.config/waybar/style"
waybar_style="${HOME}/.config/waybar/style.css"
SCRIPTSDIR="${HOME}/.config/hypr/scripts"
rofi_config="${HOME}/.config/rofi/config-waybar-style.rasi"
msg=' 🎌 NOTE: Some waybar STYLES NOT fully compatible with some LAYOUTS'

# Validate directories exist
if [[ ! -d "$waybar_styles" ]]; then
  echo "Error: waybar styles directory not found: $waybar_styles"
  exit 1
fi

# Apply selected style
apply_style() {
    local style_name="$1"
    
    if [[ ! -f "${waybar_styles}/${style_name}.css" ]]; then
      echo "Error: Style file not found: ${waybar_styles}/${style_name}.css"
      return 1
    fi
    
    ln -sf "${waybar_styles}/${style_name}.css" "$waybar_style" || return 1
    
    if [[ -x "${SCRIPTSDIR}/Refresh.sh" ]]; then
      "${SCRIPTSDIR}/Refresh.sh" &
    fi
}

main() {
    # Resolve current symlink and strip .css
    local current_target current_name
    
    if [[ -L "$waybar_style" ]]; then
      current_target=$(readlink -f "$waybar_style") || ""
      current_name=$(basename "$current_target" .css) || ""
    else
      current_name=""
    fi

    # Gather all style names (without .css) into an array
    mapfile -t options < <(
        find -L "$waybar_styles" -maxdepth 1 -type f -name '*.css' \
            -exec basename {} .css \; 2>/dev/null | sort || true
    )

    if [[ ${#options[@]} -eq 0 ]]; then
      echo "Error: No waybar style files found in $waybar_styles"
      exit 1
    fi

    # Mark the active style and record its index
    local default_row=0
    local MARKER="👉"
    for i in "${!options[@]}"; do
        if [[ "${options[i]}" == "$current_name" ]]; then
            options[i]="$MARKER ${options[i]}"
            default_row=$i
            break
        fi
    done

    # Launch rofi with the annotated list and pre‑selected row
    local choice
    choice=$(printf '%s\n' "${options[@]}" \
        | rofi -i -dmenu \
               -config "$rofi_config" \
               -mesg "$msg" \
               -selected-row "$default_row") || return 0

    [[ -z "$choice" ]] && { echo "No option selected. Exiting."; exit 0; }

    # Remove annotation and apply
    choice=${choice#"$MARKER "}
    apply_style "$choice"
}

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null 2>&1; then
    pkill rofi || true
fi

main
