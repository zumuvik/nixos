{ config, lib, pkgs, username, lib', inputs, ... }:

{
  my.profiles.server.enable = true;

  # ────────────────────────────────────────────────────────
  # Boot & Filesystems
  # ────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" ];

  # ────────────────────────────────────────────────────────
  # Sops-nix (управление секретами)
  # ────────────────────────────────────────────────────────
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.secrets."git_sync_env" = {};

  # ────────────────────────────────────────────────────────
  # Services
  # ────────────────────────────────────────────────────────

  my.services.heroku-bot = {
    enable = true;
    port = 8080;
    # domain = "heroku.samolensk.ru";
  };

  my.services.playSite.enable = true;

  my.services.crafty = {
    enable = true;
    domain = "crafty.samolensk.ru";
  };

  # TODO: добавить ключ wingsv-panel_env в secrets.yaml
  # my.services.wingsv-panel = {
  #   enable = true;
  #   publicBaseUrl = "https://panel.samolensk.ru";
  #   environmentFile = config.sops.secrets."wingsv-panel_env".path;
  # };

  # sops.secrets."wingsv-panel_env" = {};
  sops.secrets."x3-ui_env" = {};

  my.services.x3-ui = {
    enable = true;
    # panelPort = 2053;     # порт веб-панели (по умолчанию 2053)
    extraPorts = [ 8443 2096 ];
    extraPortRanges = [ { from = 2000; to = 3000; } ];
    environmentFile = config.sops.secrets."x3-ui_env".path;
    domain = "vpn.samolensk.ru";
  };

  # ────────────────────────────────────────────────────────
  # Networking
  # ────────────────────────────────────────────────────────
  networking.hostName = "nixlensk324";
  networking.nameservers = [ "1.1.1.1" ];

  my.services.valera-box.enable = true;

  # ────────────────────────────────────────────────────────
  # System packages (host-specific)
  # ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    btrfs-progs
  ];

  # ────────────────────────────────────────────────────────
  # User
  # ────────────────────────────────────────────────────────
  users.users.${username} = {
    extraGroups = [ "qemu" ];
    openssh.authorizedKeys.keys = lib'.sshKeys;
  };

  networking.firewall.allowedTCPPorts = [ 22 2222 8081 56092 25565 ];
  networking.firewall.allowedUDPPorts = [ 25565 24454 ];
  
  system.stateVersion = "25.11";
  security.pki.certificateFiles = [ ./minica_root_ca.crt ];
}
