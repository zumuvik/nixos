# /etc/nixos/configuration.nix

{ lib, pkgs, ... }:

{
  imports = [
    ./modules/profiles
  ];

  

  nix.settings = {
    substituters = [
      "https://nix-cachyos-kernel.cachix.org"
    ];
    trusted-public-keys = [
      "nix-cachyos-kernel.cachix.org-1:nE7d/3rV1BwNf55D0V6NlWz6kM4D1J9bL4oYd1WJ7A0="
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
