{ config, ... }:

{
  home.file.".config/hypr/scripts".source = ./scripts;
  home.file.".config/hypr/UserScripts".source = ./UserScripts;

  wayland.windowManager.hyprland.settings = {
     "$sD" = "${config.home.homeDirectory}/.config/hypr/scripts";
     "$uS" = "${config.home.homeDirectory}/.config/hypr/UserScripts";
     "$livewallpaper" = "mpvpaper";


     exec-once = [
      "$sD/Polkit-NixOS.sh"
      "$sD/Hyprsunset.sh init"
      "waypaper --restore"
      "Throne"
      "AyuGram"
      "kitty"
      "firefox"
      "hypridle"
      "wl-paste --type image --watch cliphist store"
      "wl-paste --type text --watch cliphist store"
      "hyprctl setcursor Bibata-Modern-Classic 24"
      "waybar & swww-daemon"
    ];
  };
}
