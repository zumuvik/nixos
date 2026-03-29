{ config, lib, pkgs, username, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      # Автологин с Hyprland
      initial_session = {
        command = "Hyprland";
        user = username;
      };

      # Fallback на tuigreet (если выйдешь из сессии)
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland --remember --remember-user-session";
        user = "greeter";
      };
    };
  };
}
