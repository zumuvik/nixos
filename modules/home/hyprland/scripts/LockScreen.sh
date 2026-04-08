#!/usr/bin/env bash
set -euo pipefail

# Optsimizirovannyj skript dlya hyprlock
# Oformlenie dokov v poyasnenii

# Obezpechivayem obnovlenie kesh pogody pered blokirovkoy
if [[ -x "$HOME/.config/hypr/UserScripts/WeatherWrap.sh" ]]; then
    bash "$HOME/.config/hypr/UserScripts/WeatherWrap.sh" >/dev/null 2>&1
fi

# Blokirovka seansa
loginctl lock-session
