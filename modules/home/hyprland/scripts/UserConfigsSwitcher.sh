#!/usr/bin/env bash
set -euo pipefail
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script to manage UserConfigs and UserConfigsBak

HYPR_CONFIG_DIR="${HOME}/.config/hypr"
USER_CONFIGS="${HYPR_CONFIG_DIR}/UserConfigs"
USER_CONFIGS_BAK="${HYPR_CONFIG_DIR}/UserConfigsBak"

if [[ -d "$USER_CONFIGS" ]] && [[ ! -d "$USER_CONFIGS_BAK" ]]; then
  echo "Moving UserConfigs to UserConfigsBak..."
  mv "$USER_CONFIGS" "$USER_CONFIGS_BAK" || {
    echo "Error: Failed to move UserConfigs"
    exit 1
  }
  echo "Done. Your UserConfigs are now in UserConfigsBak."
elif [[ ! -d "$USER_CONFIGS" ]] && [[ -d "$USER_CONFIGS_BAK" ]]; then
  echo "Moving UserConfigsBak to UserConfigs..."
  mv "$USER_CONFIGS_BAK" "$USER_CONFIGS" || {
    echo "Error: Failed to move UserConfigsBak"
    exit 1
  }
  echo "Done. Your backup has been restored to UserConfigs."
elif [[ -d "$USER_CONFIGS" ]] && [[ -d "$USER_CONFIGS_BAK" ]]; then
  echo "Both UserConfigs and UserConfigsBak exist."
  echo "Please choose what to do:"
  PS3="Enter your choice: "
  select option in "Backup current UserConfigs (move to UserConfigsBak)" "Restore backup (move UserConfigsBak to UserConfigs)" "Swap them" "Do nothing"; do
    case $REPLY in
      1)
        echo "Backing up UserConfigs..."
        rm -rf "$USER_CONFIGS_BAK"
        mv "$USER_CONFIGS" "$USER_CONFIGS_BAK" || {
          echo "Error: Failed to backup UserConfigs"
          exit 1
        }
        echo "Done. UserConfigs moved to UserConfigsBak."
        break
        ;;
      2)
        echo "Restoring backup..."
        rm -rf "$USER_CONFIGS"
        mv "$USER_CONFIGS_BAK" "$USER_CONFIGS" || {
          echo "Error: Failed to restore backup"
          exit 1
        }
        echo "Done. UserConfigsBak moved to UserConfigs."
        break
        ;;
      3)
        echo "Swapping..."
        mv "$USER_CONFIGS" "${HYPR_CONFIG_DIR}/UserConfigs.tmp" || {
          echo "Error: Failed to move UserConfigs to temp"
          exit 1
        }
        mv "$USER_CONFIGS_BAK" "$USER_CONFIGS" || {
          echo "Error: Failed to move UserConfigsBak"
          exit 1
        }
        mv "${HYPR_CONFIG_DIR}/UserConfigs.tmp" "$USER_CONFIGS_BAK" || {
          echo "Error: Failed to move temp to UserConfigsBak"
          exit 1
        }
        echo "Done. UserConfigs and UserConfigsBak have been swapped."
        break
        ;;
      4)
        echo "No changes made."
        break
        ;;
      *)
        echo "Invalid option. Please try again."
        ;;
    esac
  done
else
  echo "Neither UserConfigs nor UserConfigsBak directory found. Nothing to do."
fi
