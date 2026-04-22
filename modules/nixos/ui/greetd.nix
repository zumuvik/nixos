{ config, lib, pkgs, username, ... }:

{
  options.my.ui.greetd.enable = lib.mkEnableOption "greetd login manager with ReGreet";

  config = lib.mkIf config.my.ui.greetd.enable {
    # ReGreet needs a compositor to run. Cage is a tiny kiosk compositor.
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.getExe pkgs.cage} -s -- ${lib.getExe pkgs.greetd.regreet}";
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
