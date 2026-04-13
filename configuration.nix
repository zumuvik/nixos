# /etc/nixos/configuration.nix

{ lib, pkgs, ... }:

{
  imports = [
    ./modules/system
  ];

  # This file is now a thin wrapper. 
  # Most settings moved to modules/profiles/core.nix
  
  # Bootloader settings (global default)
  boot.loader = {
    systemd-boot.enable = lib.mkDefault false;
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      device = lib.mkDefault "nodev";
      efiSupport = true;
      useOSProber = false;
    };
    grub2-theme = {
      enable = true;
      theme = "tela";
    };
  };

  # Global defaults for common services
  networking.firewall.checkReversePath = "loose";

  # Nix-LD for non-nixos binaries
  programs.nix-ld.enable = true;

  # Home Manager global settings
  home-manager.backupFileExtension = "backup";

  # System State Version
  system.stateVersion = lib.mkDefault "24.11";
}
