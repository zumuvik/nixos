# /etc/nixos/configuration.nix

{ lib, pkgs, ... }:

{
  imports = [
    ./modules/profiles
  ];

  

  nix.settings = {
    substituters = [
      "https://drakon64-nixos-cachyos-kernel.cachix.org"
    ];
    trusted-public-keys = [
      "drakon64-nixos-cachyos-kernel.cachix.org-1:J3gjZ9N6S05pyLA/P0M5y7jXpSxO/i0rshrieQJi5D0="
    ];
  };

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
