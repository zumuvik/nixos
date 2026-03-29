{ config, lib, pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -- ${pkgs.regreet}/bin/regreet";
        user = "greeter";
      };
    };
  };

  programs.regreet = {
    enable = true;
    settings = {
      appearance = {
        greeting_msg = "Welcome back";
      };
      GTK = {
        application_prefer_dark_theme = lib.mkForce true;
        cursor_theme_name = lib.mkForce "Bibata-Modern-Classic";
        font_name = lib.mkForce "JetBrains Mono";
        theme_name = lib.mkForce "Adwaita-dark";
      };
    };
  };
}
