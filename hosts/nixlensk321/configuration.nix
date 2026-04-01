{ config, lib, pkgs, username, ... }:

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
  # ────────────────────────────────────────────────────────
  # User
  # ────────────────────────────────────────────────────────
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

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
  # Disable TPM (no TPM chip)
  # ────────────────────────────────────────────────────────
  systemd.services.systemd-tpm2-setup.enable = false;
  systemd.sockets.systemd-tpm2-setup-auto.enable = false;

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
    grim
    slurp
    wl-clipboard
    mako
    swww
    btop
    fastfetch
    networkmanagerapplet
    pavucontrol
  ];
}
