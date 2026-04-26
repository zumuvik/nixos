{ config, ... }:

{
  wayland.windowManager.hyprland.settings = {
     "$sD" = "${config.home.homeDirectory}/.config/hypr/scripts";
     "$uS" = "${config.home.homeDirectory}/.config/hypr/UserScripts";
     "$livewallpaper" = "mpvpaper";

     exec-once = [
       "gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'"
       "gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'"
       "gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'"
       "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
       "$sD/Polkit-NixOS.sh"
       "$sD/Hyprsunset.sh init"
       "waypaper --restore"
       "Throne"
       "AyuGram"
       "kitty"
"zen"
      "wl-paste --type image --watch cliphist store"
       "wl-paste --type text --watch cliphist store"
       "hyprctl setcursor Bibata-Modern-Classic 24"
       "waybar & awww-daemon"
       "swaync"
      ];
  };
}
