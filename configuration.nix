# /etc/nixos/configuration.nix

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hosts/nixlensk323/hardware-configuration.nix
    ./modules/system
  ];

  # ────────────────────────────────────────────────────────
  # Boot & Kernel (общее для всех хостов)
  # ────────────────────────────────────────────────────────
    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = false;
      };
      grub2-theme = {
        enable = true;
        theme = "tela";
      };
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

  programs.nix-ld.enable = true;


  # ────────────────────────────────────────────────────────
  # Console (общее)
  # ────────────────────────────────────────────────────────
  console.useXkbConfig = true;

  # ────────────────────────────────────────────────────────
  # Locale & i18n (общее для всех)
  # ────────────────────────────────────────────────────────
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
    LANG = "ja_JP.UTF-8";
  };


  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      noto-fonts-cjk-serif
      noto-fonts
      noto-fonts-color-emoji
      dejavu_fonts
      liberation_ttf          # ← Правильно!
    ];
  };
  # ────────────────────────────────────────────────────────
  # Home Manager (общее)
  # ────────────────────────────────────────────────────────
  home-manager.backupFileExtension = "backup";

  # ────────────────────────────────────────────────────────
  # System State Version (НЕ МЕНЯЙ)
  # ────────────────────────────────────────────────────────
  system.stateVersion = "24.11";
}
