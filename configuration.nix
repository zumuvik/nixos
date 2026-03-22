# /etc/nixos/configuration.nix
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./hosts/nixlensk323/system.nix
    ./hosts/nixlensk323/zumuvik.nix
    ./modules/system/services.nix
    ./modules/system/hardware.nix
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
  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  console.useXkbConfig = true;

  nix.gc = {
  automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    nixpkgs.config.allowUnfree = true;


    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };




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
  programs.throne = {
    enable = true;
    tunMode = {
      enable = true;
      setuid = true;
    };
  };



  # ────────────────────────────────────────────────
  # Hardware
  # ────────────────────────────────────────────────
  home-manager.backupFileExtension = "backup";
  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi
      obs-pipewire-audio-capture
      wlrobs
      obs-vkcapture
      obs-gstreamer
    ];
  };

  # Важно для AMD VAAPI
  hardware.graphics = {
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

  services.blueman.enable = true;
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
        PasswordAuthentication = false;
    };
  };

  # ────────────────────────────────────────────────
  # Misc / Compatibility
  # ────────────────────────────────────────────────
  system.stateVersion = "25.11";            # НЕ МЕНЯЙ без прочтения комментария!
}
