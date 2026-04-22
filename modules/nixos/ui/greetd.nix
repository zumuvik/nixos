{ config, lib, pkgs, username, ... }:

let
  # Minimal Hyprland config for the greeter
  greetdHyprConfig = pkgs.writeText "greetd-hyprland.conf" ''
    monitor=HDMI-A-1,preferred,0x0,1
    monitor=,disable
    exec-once = ${lib.getExe pkgs.greetd.regreet}; hyprctl dispatch exit
  '';
in
{
  options.my.ui.greetd.enable = lib.mkEnableOption "greetd login manager with ReGreet";

  config = lib.mkIf config.my.ui.greetd.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # Use Hyprland instead of cage for better monitor control
          command = "${lib.getExe pkgs.hyprland} --config ${greetdHyprConfig}";
          user = "greeter";
        };
      };
    };

    programs.regreet = {
      enable = true;
      settings = {
        background = {
          path = "/home/${username}/.config/hypr/hyprlock.png";
          fit = "Fill";
        };
        gtkgreet = {
          command = "Hyprland";
        };
        appearance = {
          greeting = "Welcome to ${config.networking.hostName}";
        };
      };
    };

    # Ensure the greeter user has access to the background image
    systemd.services.greetd.serviceConfig = {
      SupplementaryGroups = [ "users" ];
    };
  };
}
