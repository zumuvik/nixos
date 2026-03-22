{ config, ... }:

{
  home.file.".config/hypr/scripts".source = ./scripts;
  home.file.".config/hypr/UserScripts".source = ./UserScripts;

  wayland.windowManager.hyprland.settings = {
     "$sD" = "${config.home.homeDirectory}/.config/hypr/scripts";
     "$uS" = "${config.home.homeDirectory}/.config/hypr/UserScripts";

    "exec-once" = [
      "$sD/Polkit.sh"
      "$sD/Hyprsunset.sh init"
      "waypaper --restore"
    ];
  };
}
