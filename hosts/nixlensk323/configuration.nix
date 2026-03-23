{ config, pkgs, ... }:

{
  # ────────────────────────────────────────────────────────
  # Networking & Hostname (хост-специфичные)
  # ────────────────────────────────────────────────────────
  networking.hostName = "nixlensk323";
  time.timeZone = "Europe/Moscow";

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  networking.networkmanager.enable = true;
  programs.fish.enable = true;

  # ────────────────────────────────────────────────────────
  # Swap (хост-специфичный)
  # ────────────────────────────────────────────────────────
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32768;
    }
  ];

  # ────────────────────────────────────────────────────────
  # Users (хост-специфичные)
  # ────────────────────────────────────────────────────────
  users.users.zumuvik = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm" "qemu" "disk" ];
    shell = pkgs.fish;
  };

  # ────────────────────────────────────────────────────────
  # Sudo configuration (хост-специфичный)
  # ────────────────────────────────────────────────────────
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

  # ────────────────────────────────────────────────────────
  # Hyprland/Wayland setup
  # ────────────────────────────────────────────────────────
  programs.throne = {
    enable = true;
    tunMode = {
      enable = true;
      setuid = true;
    };
  };

  # ────────────────────────────────────────────────────────
  # Hardware-specific (для этого ПК)
  # ────────────────────────────────────────────────────────
  hardware.graphics.enable = true;
  hardware.opentabletdriver.enable = true;
  hardware.uinput.enable = true;
  boot.kernelModules = [ "uinput" ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;
  networking.wireguard.enable = true;

  # ────────────────────────────────────────────────────────
  # System packages (хост-специфичные, если нужны)
  # ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    osu-lazer-bin
    git
    wget
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
    pavucontrol
    nix-search
  ];
}
