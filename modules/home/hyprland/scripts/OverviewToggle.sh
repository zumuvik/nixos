#!/usr/bin/env bash
set -euo pipefail

# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Optsimizirovannyj skript dlya overview toggle

# Try Quickshell first
if pgrep -x quickshell >/dev/null 2>&1; then
    if qs ipc -c overview call overview toggle >/dev/null 2>&1; then
        exit 0
    fi
fi

# Try to start QS and retry
if command -v qs >/dev/null 2>&1; then
    qs -c overview >/dev/null 2>&1 &
    sleep 0.6
    if qs ipc -c overview call overview toggle >/dev/null 2>&1; then
        exit 0
    fi
fi

# Fall back to AGS
if command -v ags >/dev/null 2>&1; then
    pkill rofi 2>/dev/null || true
    if ags -t 'overview' >/dev/null 2>&1; then
        exit 0
    fi
    ags >/dev/null 2>&1 &
    sleep 0.6
    if ags -t 'overview' >/dev/null 2>&1; then
        exit 0
    fi
fi

# Fallback error
notify-send "Overview" "Neither Quickshell nor AGS is available" -u low 2>/dev/null || true
exit 1
