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
  networking.hostName = "nixlensk323";          # ← раскомментируй и поменяй при желании
  programs.fish.enable = true;
  time.timeZone = "Europe/Moscow";
  systemd.network.networks."40-enp8s0" = {
    matchConfig.Name = "enp8s0";
    # Настройка адреса (если не DHCP)
    address = [ "192.168.3.155/24" ];

    # Вот тут магия маршрутов с метриками
    routes = [
      {
        # Основной путь через сервер
        Gateway = "192.168.3.1";
        GatewayOnLink = true;
        Metric = 10;
      }
      {
        # Резервный путь через роутер
        Gateway = "192.168.1.1";
        GatewayOnLink = true;
        Metric = 100;
      }
    ];
  };


  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  console.useXkbConfig = true;   # применяет раскладку также в tty

  nix.gc = {
  automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };

  systemd.timers.nix_gc = {
    enable = true;
    unitConfig.Timer = "OnCalendar=daily";
  };


    # Разрешаем несвободные пакеты (Discord, NVIDIA драйверы, Steam и т.д.)
    nixpkgs.config.allowUnfree = true;

    # Твой остальной конфиг...


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
   shell = pkgs.fish;      # лучше вынести в home-manager
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
    btop
    xrandr hyprlock pkgs.opentabletdriver
    nwg-look
    # terminal & basics
    fastfetch
    kitty
    zip unzip
    git
    nwg-displays
    wlr-randr cliphist wl-clipboard
    # wayland utils

    mako mpvpaper remmina
      mpv fish
    swww waypaper spotube scrcpy
    grim gh wireguard-tools
    slurp android-tools
    rofi   playerctl
    wl-clipboard libnotify

    # apps
    pavucontrol
    kdePackages.qtsvg
    kdePackages.kio # needed since 25.11
        kdePackages.kio-fuse #to mount remote filesystems via FUSE
        kdePackages.kio-extras #extra protocols support (sftp, fish and more)
        kdePackages.dolphin
    nix-search            # поиск по пакетам nix
  ];

  # В файле configuration.nix или home-manager
  fonts.packages = with pkgs; [
   nerd-fonts.jetbrains-mono
   nerd-fonts.iosevka
  ];


  # ────────────────────────────────────────────────
  # Misc / Compatibility
  # ────────────────────────────────────────────────
  system.stateVersion = "26.05";            # НЕ МЕНЯЙ без прочтения комментария!
}
