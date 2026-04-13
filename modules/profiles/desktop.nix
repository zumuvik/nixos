{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.modules.desktop.enable {
    # ────────────────────────────────────────────────────────
    # Desktop Profile Settings
    # ────────────────────────────────────────────────────────
    
    # UI & Graphics
    services.xserver.videoDrivers = [ "amdgpu" ];
    boot.initrd.kernelModules = [ "amdgpu" ];
    
    # Audio (PipeWire)
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
    security.rtkit.enable = true;

    # UI & Graphics (AMD/Intel)
    hardware.graphics.enable = true;

    # Fonts
    fonts.packages = with pkgs; [
      inter
      nerd-fonts.symbols-only
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];

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

    # Misc
    programs.nix-ld.enable = true;
    
    # Environment
    environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "gtk";
      GTK_THEME = "Adwaita-dark";
    };
  };
}
