# /etc/nixos/configuration.nix

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./modules/system
  ];

  # ────────────────────────────────────────────────────────
  # Boot & Kernel (общее для всех хостов)
  # ────────────────────────────────────────────────────────
  boot.loader = {
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
  # Dark Theme (общее для всех)
  # ────────────────────────────────────────────────────────
  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "gtk";
    GTK_THEME = "Adwaita-dark";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };

  # ────────────────────────────────────────────────────────
  # Fonts (общее для всех)
  # ────────────────────────────────────────────────────────
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      jetbrains-mono
      noto-fonts-cjk-serif
      noto-fonts
      noto-fonts-color-emoji
      dejavu_fonts
      liberation_ttf
      (pkgs.stdenv.mkDerivation {
        pname = "sf-pro-display";
        version = "1.0";
        dontUnpack = true;
        srcs = [
          (pkgs.fetchurl {
            name = "sf-pro-bold.otf";
            url = "https://raw.githubusercontent.com/MrVivekRajan/Hyprlock-Styles/main/Style-9/Fonts/SF%20Pro%20Display/SF%20Pro%20Display%20Bold.otf";
            sha256 = "0pqv47piw79jglk641dripxmdpcgzr673kgiws9y7mmy9l9cxd8w";
          })
          (pkgs.fetchurl {
            name = "sf-pro-regular.otf";
            url = "https://raw.githubusercontent.com/MrVivekRajan/Hyprlock-Styles/main/Style-9/Fonts/SF%20Pro%20Display/SF%20Pro%20Display%20Regular.otf";
            sha256 = "1kxj8hc9ckzgskwz78b9ijikbpy755808xzfllg9wbya01wd3d6z";
          })
        ];
        installPhase = ''
          mkdir -p $out/share/fonts/opentype
          for src in $srcs; do
            cp $src $out/share/fonts/opentype/
          done
        '';
      })
    ];
  };

  # ────────────────────────────────────────────────────────
  # Locale & i18n (общее для всех)
  # ────────────────────────────────────────────────────────
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_MESSAGES = "ru_RU.UTF-8";
    LC_COLLATE = "ru_RU.UTF-8";
    LC_CTYPE = "ru_RU.UTF-8";
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
