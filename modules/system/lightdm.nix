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

  # Hyprland session for LightDM
  services.xserver.displayManager.session = [
    {
      manage = "desktop";
      name = "Hyprland";
      start = ''
        exec Hyprland
      '';
    }
  ];
}
