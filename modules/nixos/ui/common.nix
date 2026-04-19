{ config, lib, pkgs, ... }:

{
  options.my.ui.common.enable = lib.mkEnableOption "Common Desktop UI components (Audio, Portal, Keyboard)";

  config = lib.mkIf config.my.ui.common.enable {
    # Audio (PipeWire)
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
    security.rtkit.enable = true;

    # Portal
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };

    # Keyboard layout
    services.xserver.xkb = {
      layout = "us,ru";
      options = "grp:alt_shift_toggle";
    };
    
    # Graphics base
    hardware.graphics.enable = lib.mkDefault true;
  };
}
