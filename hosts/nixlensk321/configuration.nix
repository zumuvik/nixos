{ config, pkgs, username, ... }:

{
  # ────────────────────────────────────────────────────────
  # Networking & Hostname
  # ────────────────────────────────────────────────────────
  networking.hostName = "nixlensk321";
  time.timeZone = "Europe/Moscow";

  networking.networkmanager.enable = true;

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  programs.fish.enable = true;

  # ────────────────────────────────────────────────────────
  # User
  # ────────────────────────────────────────────────────────
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm" ];
    shell = pkgs.fish;
  };

  # ────────────────────────────────────────────────────────
  # sudo без пароля на nixos-rebuild switch
  # ────────────────────────────────────────────────────────
  security.sudo.extraRules = [
    {
      users = [ "${username}" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild switch";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # ────────────────────────────────────────────────────────
  # Swap + Zram
  # ────────────────────────────────────────────────────────
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 10;
  };

  # ────────────────────────────────────────────────────────
  # System packages (laptop-specific)
  # ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    osu-lazer-bin
    git
    wget
    gh
    wireguard-tools
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
  ];
}
