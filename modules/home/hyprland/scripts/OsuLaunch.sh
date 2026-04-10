#!/usr/bin/env bash
set -euo pipefail

# Переключаемся на 9 рабочее место
hyprctl dispatch workspace 9

# Запускаем OpenTabletDriver и osu!
otd-daemon &
sleep 1
otd-gui &
sleep 0.5
osu-lazer-bin &
