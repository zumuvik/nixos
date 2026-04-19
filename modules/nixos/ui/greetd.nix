{ config, lib, pkgs, ... }:

{
  options.my.ui.greetd.enable = lib.mkEnableOption "greetd login manager with tuigreet";

  config = lib.mkIf config.my.ui.greetd.enable {
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
