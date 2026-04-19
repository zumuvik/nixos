{ config, lib, pkgs, ... }:

{
  # Hypridle (Screen lock/sleep/hibernate)
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 300; on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
        { timeout = 600; on-timeout = "hyprctl dispatch switchxkblayout all en && loginctl lock-session"; }
        { timeout = 900; on-timeout = "systemctl suspend"; }
      ];
    };
  };

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "hypridle"
    ];
  };
}