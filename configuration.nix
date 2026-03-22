# /etc/nixos/configuration.nix

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system
  ];

  # ────────────────────────────────────────────────────────
  # Boot & Kernel (общее для всех хостов)
  # ────────────────────────────────────────────────────────
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # ────────────────────────────────────────────────────────
  # Nix Settings (общее)
  # ────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # ────────────────────────────────────────────────────────
  # Console (общее)
  # ────────────────────────────────────────────────────────
  console.useXkbConfig = true;

  # ────────────────────────────────────────────────────────
  # Fonts (общее для всех)
  # ────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
  ];

  # ────────────────────────────────────────────────────────
  # Home Manager (общее)
  # ────────────────────────────────────────────────────────
  home-manager.backupFileExtension = "backup";

  # ────────────────────────────────────────────────────────
  # System State Version (НЕ МЕНЯЙ)
  # ────────────────────────────────────────────────────────
  system.stateVersion = "25.11";
}
