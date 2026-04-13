#!/usr/bin/env bash
set -euo pipefail

# Optsimizirovannyj skript dlya periklyucheniya temy (Light/Dark)

iDIR="$HOME/.config/swaync/images"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

# Puti
PICTURES_DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"
wallpaper_base="$PICTURES_DIR/wallpapers/Dynamic-Wallpapers"
dark_wall="$wallpaper_base/Dark"
light_wall="$wallpaper_base/Light"

config_cache="$HOME/.cache/.theme_mode"
wallust_config="$HOME/.config/wallust/wallust.toml"

swaync_style="$HOME/.config/swaync/style.css"
ags_style="$HOME/.config/ags/user/style.css"
kitty_conf="$HOME/.config/kitty/kitty.conf"

qt5ct_dark="$HOME/.config/qt5ct/colors/Catppuccin-Mocha.conf"
qt5ct_light="$HOME/.config/qt5ct/colors/Catppuccin-Latte.conf"
qt6ct_dark="$HOME/.config/qt6ct/colors/Catppuccin-Mocha.conf"
qt6ct_light="$HOME/.config/qt6ct/colors/Catppuccin-Latte.conf"

# Proverka faila sohraneniya
[[ -f "$config_cache" ]] || echo "Dark" > "$config_cache"

# Opredelenietekushey temy
current_mode=$(cat "$config_cache")
if [[ "$current_mode" == "Light" ]]; then
    next_mode="Dark"
else
    next_mode="Light"
fi

# Inicializaciya awww
awww query >/dev/null 2>&1 || awww-daemon --format xrgb

awww="awww img"
effect="--transition-bezier .43,1.19,1,.4 --transition-fps 60 --transition-type grow --transition-pos 0.925,0.977 --transition-duration 2"

# Update wallust config
if [[ "$next_mode" == "Dark" ]]; then
    sed -i 's/^palette =.*/palette = "dark16"/' "$wallust_config"
else
    sed -i 's/^palette =.*/palette = "light16"/' "$wallust_config"
fi

# Update waybar styles
waybar_style_dir="$HOME/.config/waybar/style"
waybar_style_link="$HOME/.config/waybar/style.css"

if [[ -d "$waybar_style_dir" ]]; then
    style_file=$(find -L "$waybar_style_dir" -maxdepth 1 -type f -regex ".*$next_mode.*CSS" 2>/dev/null | shuf -n 1)
    if [[ -n "$style_file" ]]; then
        ln -sf "$style_file" "$waybar_style_link"
    fi
fi

# Update swaync
if [[ "$next_mode" == "Dark" ]]; then
    sed -i '/@define-color noti-bg/s/rgba([0-9][^)]*/rgba(0, 0, 0, 0.8)/' "$swaync_style"
else
    sed -i '/@define-color noti-bg/s/rgba([0-9][^)]*/rgba(255, 255, 255, 0.9)/' "$swaync_style"
fi

# Update ags
if command -v ags >/dev/null 2>&1; then
    if [[ "$next_mode" == "Dark" ]]; then
        sed -i '/@define-color noti-bg/s/rgba([0-9][^)]*/rgba(0, 0, 0, 0.4)/' "$ags_style"
        sed -i '/@define-color text-color/s/rgba([0-9][^)]*/rgba(255, 255, 255, 0.7)/' "$ags_style"
    else
        sed -i '/@define-color noti-bg/s/rgba([0-9][^)]*/rgba(255, 255, 255, 0.4)/' "$ags_style"
        sed -i '/@define-color text-color/s/rgba([0-9][^)]*/rgba(0, 0, 0, 0.7)/' "$ags_style"
    fi
fi

# Update kitty
if [[ "$next_mode" == "Dark" ]]; then
    sed -i '/^foreground /s/^foreground .*/foreground #dddddd/' "$kitty_conf"
    sed -i '/^background /s/^background .*/background #000000/' "$kitty_conf"
else
    sed -i '/^foreground /s/^foreground .*/foreground #000000/' "$kitty_conf"
    sed -i '/^background /s/^background .*/background #dddddd/' "$kitty_conf"
fi

# Restart kitty
pkill -SIGUSR1 -f "^kitty$" 2>/dev/null || true

# Set wallpaper (randomly)
if [[ -d "$dark_wall" && -d "$light_wall" ]]; then
    if [[ "$next_mode" == "Dark" ]]; then
        wp=$(find "$dark_wall" -type f \( -iname "*.jpg" -o -iname "*.png" \) -print0 | shuf -n1 -z | xargs -0)
    else
        wp=$(find "$light_wall" -type f \( -iname "*.jpg" -o -iname "*.png" \) -print0 | shuf -n1 -z | xargs -0)
    fi
    [[ -n "$wp" ]] && $awww "$wp" $effect >/dev/null 2>&1 || true
fi

# Update Qt5ct/Qt6ct
if [[ "$next_mode" == "Dark" ]]; then
    sed -i "s|^color_scheme_path=.*$|color_scheme_path=$qt5ct_dark|" "$HOME/.config/qt5ct/qt5ct.conf"
    sed -i "s|^color_scheme_path=.*$|color_scheme_path=$qt6ct_dark|" "$HOME/.config/qt6ct/qt6ct.conf"
else
    sed -i "s|^color_scheme_path=.*$|color_scheme_path=$qt5ct_light|" "$HOME/.config/qt5ct/qt5ct.conf"
    sed -i "s|^color_scheme_path=.*$|color_scheme_path=$qt6ct_light|" "$HOME/.config/qt6ct/qt6ct.conf"
fi

# Update Kvantum
kvantum_theme=$(if [[ "$next_mode" == "Dark" ]]; then echo "catppuccin-mocha-blue"; else echo "catppuccin-latte-blue"; fi)
command -v kvantummanager >/dev/null 2>&1 && kvantummanager --set "$kvantum_theme" 2>/dev/null || true

# Update rofi colors
wallust_rofi="$HOME/.config/wallust/templates/colors-rofi.rasi"
if [[ -f "$wallust_rofi" ]]; then
    if [[ "$next_mode" == "Dark" ]]; then
        sed -i '/^background:/s/.*/background: rgba(0,0,0,0.7);/' "$wallust_rofi"
    else
        sed -i '/^background:/s/.*/background: rgba(255,255,255,0.9);/' "$wallust_rofi"
    fi
fi

# GTK theme selection
set_gtk_theme() {
    local mode=$1
    local search_kw color_scheme
    
    if [[ "$mode" == "Light" ]]; then
        search_kw="*Light*"
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    else
        search_kw="*Dark*"
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    fi
    
    # Theme selection
    local themes=()
    while IFS= read -r -d '' theme; do
        themes+=("$(basename "$theme")")
    done < <(find "$HOME/.themes" -maxdepth 1 -type d -iname "$search_kw" -print0 2>/dev/null)
    
    if [[ ${#themes[@]} -gt 0 ]]; then
        local selected=${themes[RANDOM % ${#themes[@]}]}
        gsettings set org.gnome.desktop.interface gtk-theme "$selected"
        
        # Flatpak override
        command -v flatpak >/dev/null 2>&1 && {
            flatpak --user override --filesystem="$HOME/.themes" >/dev/null 2>&1
            flatpak --user override --env="GTK_THEME=$selected" >/dev/null 2>&1
        }
    fi
    
    # Icon theme
    local icons=()
    while IFS= read -r -d '' icon; do
        icons+=("$(basename "$icon")")
    done < <(find "$HOME/.icons" -maxdepth 1 -type d -iname "$search_kw" -print0 2>/dev/null)
    
    if [[ ${#icons[@]} -gt 0 ]]; then
        local selected=${icons[RANDOM % ${#icons[@]}]}
        gsettings set org.gnome.desktop.interface icon-theme "$selected"
        
        # Update qt5ct/qt6ct icons
        sed -i "s|^icon_theme=.*$|icon_theme=$selected|" "$HOME/.config/qt5ct/qt5ct.conf"
        sed -i "s|^icon_theme=.*$|icon_theme=$selected|" "$HOME/.config/qt6ct/qt6ct.conf"
        
        # Flatpak icons override
        command -v flatpak >/dev/null 2>&1 && {
            flatpak --user override --filesystem="$HOME/.icons" >/dev/null 2>&1
            flatpak --user override --env="ICON_THEME=$selected" >/dev/null 2>&1
        }
    fi
}

set_gtk_theme "$next_mode"

# Reload config - only at the end
notify-send -u low -i "$iDIR/bell.png" "Periklyuchenie" "$next_mode"

$SCRIPTSDIR/WallustSwww.sh || true
sleep 2

# Restart affected processes
for proc in waybar rofi swaync ags swaybg; do
    pkill -SIGUSR1 "$proc" 2>/dev/null || true
done

sleep 0.5
$SCRIPTSDIR/Refresh.sh || true

