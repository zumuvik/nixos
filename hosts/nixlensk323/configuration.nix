{ config, pkgs, ... }:

{
  # ────────────────────────────────────────────────────────
  # Networking & Hostname (хост-специфичные)
  # ────────────────────────────────────────────────────────
  networking.hostName = "nixlensk323";
  time.timeZone = "Europe/Moscow";

  boot = {
      resumeDevice = "/dev/disk/by-uuid/6703b7a2-d8ba-4f63-8fc0-5d770b59df7f";
      kernelParams = [
        "resume_offset=4988160"
      ];
     };
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  networking.networkmanager.enable = true;
  programs.fish.enable = true;
  networking.firewall.checkReversePath = "loose";
  # ────────────────────────────────────────────────────────
  # Swap (хост-специфичный)
  # ────────────────────────────────────────────────────────
  # Примечание: swapDevices в hardware-configuration.nix = [],
  # этот swapfile добавляется отдельно
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32768;
    }
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 10;
  };

  # ────────────────────────────────────────────────────────
  # Про zumuvik
  # ────────────────────────────────────────────────────────
  users.users.zumuvik = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm" "qemu" "disk" ];
    shell = pkgs.fish;
  };

  # ────────────────────────────────────────────────────────
  # sudo без пароля на nixos-rebuild switch
  # ────────────────────────────────────────────────────────
  security.sudo.extraRules = [
    {
      users = [ "zumuvik" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild switch";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Для трансляций
    dedicatedServer.openFirewall = true; # Для серверов
    extraPackages = with pkgs; [
      mangohud # Тот самый оверлей с FPS и температурами (как на Steam Deck)
      gamemode # Оптимизация проца и видюхи под игру
    ];
  };

  # ────────────────────────────────────────────────────────
  # VLESS cleint
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
  # hardware.graphics, bluetooth, opentabletdriver, uinput
  # уже определены в modules/system/hardware.nix

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
    opencode
    fastfetch
    playerctl
    networkmanagerapplet
    pavucontrol
    nix-search
  ];
}
