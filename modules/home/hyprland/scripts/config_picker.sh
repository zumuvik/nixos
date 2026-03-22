#!/bin/bash

CONF_DIR="$HOME/.config/hypr"
# Укажи свой терминал (kitty/foot/alacritty)
TERM_BIN="kitty" 

# Генерируем список только .conf файлов
CHOICE=$(find "$CONF_DIR" -maxdepth 1 -name "*.conf" -printf "%f\n" | rofi -dmenu -i -p "Select Config:")

# Если выбор сделан
if [ -n "$CHOICE" ]; then
    # Пробуем запустить micro внутри терминала
    $TERM_BIN micro "$CONF_DIR/$CHOICE"
fi
