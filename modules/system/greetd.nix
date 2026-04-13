{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.desktop.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd hyprland";
          user = "greeter";
        };
      };
    };
  };
}
