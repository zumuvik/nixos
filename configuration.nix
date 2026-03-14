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
  networking.networkmanager.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName = "nixlensk323";          # ← раскомментируй и поменяй при желании
  programs.fish.enable = true;
  # ────────────────────────────────────────────────
  # Time & Localization
  # ────────────────────────────────────────────────
  # time.timeZone = "Europe/Amsterdam";     # ← включи нужный регион
  # i18n.defaultLocale = "en_US.UTF-8";

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
    extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm" "qemu" ];
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
    aqemu
    btop
    xrandr
    nwg-look
    bibata-cursors
    discord
    
    steam
    # terminal & basics
    fastfetch
    micro
    kitty
    htop zip unzip
    git vesktop
    nwg-displays
    wlr-randr cliphist wl-clipboard
    # wayland utils
    waybar
    mako mpvpaper remmina
      mpv fish 
    swww waypaper spotube scrcpy
    grim gh wireguard-tools
    slurp android-tools
    rofi   playerctl       # или wofi — выбери один
    # wofi
    wl-clipboard libnotify
    inputs.ayugram-desktop.packages.${pkgs.system}.ayugram-desktop
    # apps
    firefox
    pavucontrol
    cava
    throne                   # уже тянется через programs.throne, но на всякий
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
