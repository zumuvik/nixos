{ pkgs, lib, ... }:
{
  imports = [
    ./binds.nix
    ./style.nix
    ./monitors.nix
    ./exec-once.nix
    ./scripts.nix
    ./hyprlock.nix
    ./swaync.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  wayland.windowManager.hyprland.settings = lib.mkMerge [
    {
      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad.natural_scroll = false;
        scroll_method = "on_button_down";
        scroll_button = 276;
        scroll_button_lock = false;
        scroll_factor = 1.0;
      };
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      # gestures (disabled - causes errors)
      # workspace_swipe config moved to binds/KeyBinds.sh
      env = [
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
      ];
      windowrule = [
        "suppress_event maximize, match:class .*"

      ];
    }
  ];
}
