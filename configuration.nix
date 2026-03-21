# /etc/nixos/configuration.nix
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ────────────────────────────────────────────────
  # Boot & Kernel
  # ────────────────────────────────────────────────
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # ────────────────────────────────────────────────
  # Networking
  # ────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName = "nixlensk323";
  programs.fish.enable = true;
  time.timeZone = "Europe/Moscow";
  networking.networkmanager.enable = true;


  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  console.useXkbConfig = true;

  nix.gc = {
  automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };

  systemd.timers.nix_gc = {
    enable = true;
    unitConfig.Timer = "OnCalendar=daily";
  };


    nixpkgs.config.allowUnfree = true;




  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32768;
    }
  ];


  # ────────────────────────────────────────────────
  # Users
  # ────────────────────────────────────────────────
  users.users.zumuvik = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm" "qemu" "disk" ];
   shell = pkgs.fish;
  };
  security.sudo.extraRules = [
    {
      users = [ "zumuvik" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/micro /etc/nixos/configuration.nix";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nixos-rebuild switch";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];



  # ────────────────────────────────────────────────
  # Desktop / Wayland / Hyprland
  # ────────────────────────────────────────────────
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
     withUWSM = true;                     # ← можно включить в 2025+ для лучшей стабильности сессии
  };

  # Throne (GUI прокси-менеджер с TUN-режимом)
  programs.throne = {
    enable = true;
    tunMode = {
      enable = true;
      setuid = true;                     # создаёт SUID-враппер
    };
  };



  # ────────────────────────────────────────────────
  # Hardware
  # ────────────────────────────────────────────────
  home-manager.backupFileExtension = "backup";
  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi                # аппаратное ускорение AMD (Vega)
      obs-pipewire-audio-capture
      wlrobs                   # захват экрана на Wayland
      obs-vkcapture            # захват игр через Vulkan
      obs-gstreamer
    ];
  };

  # Важно для AMD VAAPI
  hardware.opengl = {
    enable = true;

  };



 hardware.opentabletdriver.enable = true;
 hardware.uinput.enable = true;
  boot.kernelModules = [ "uinput" ];
security.rtkit.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;           # удобный bluetooth gui
  networking.wireguard.enable = true;



  # ────────────────────────────────────────────────
  # Packages (system-wide — только необходимое)
  # ────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    osu-lazer-bin
  git
  gh
  wireguard-tools
  zip
  unzip
  unrar
  xrandr
  brightnessctl
  opentabletdriver
  grim
  slurp
  wl-clipboard
  mako
  swww
  hyprlock
  btop
  fastfetch
  playerctl
  networkmanagerapplet

    # apps
    pavucontrol
    nix-search            # поиск по пакетам nix
  ];

  # В файле configuration.nix или home-manager
  fonts.packages = with pkgs; [
   nerd-fonts.jetbrains-mono
   nerd-fonts.iosevka
  ];

  services.openssh = {
    enable = true;
    settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
    };
  };

  # ────────────────────────────────────────────────
  # Misc / Compatibility
  # ────────────────────────────────────────────────
  system.stateVersion = "26.05";            # НЕ МЕНЯЙ без прочтения комментария!
}
