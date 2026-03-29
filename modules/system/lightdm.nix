{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;

  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
      extraConfig = ''
        font-name = JetBrains Mono 11
        user-background = false
      '';
    };
  };

  # Register Hyprland as a Wayland session for LightDM
  environment.etc."wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=An intelligent dynamic tiling Wayland compositor
    Exec=Hyprland
    Type=Application
    DesktopNames=Hyprland
  '';

  # Set Hyprland as default session
  services.xserver.displayManager.defaultSession = "hyprland";
}
