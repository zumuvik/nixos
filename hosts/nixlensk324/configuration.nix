{ config, lib, pkgs, username, lib', ... }:

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
  sops.secrets."cloudflare_env" = {};

  # ────────────────────────────────────────────────────────
  # Services
  # ────────────────────────────────────────────────────────


  my.services.cloudflare-sync = {
    enable = true;
    checkInterval = "hourly";
    domains = [
      { zone = "samolensk.ru"; records = [ ]; }
    ];
  };

  sops.secrets."x3-ui_env" = {};

  my.services.x3-ui = {
    enable = true;
    # panelPort = 2053;  # порт веб-панели (по умолчанию 2053)
    # vlessPort = 443;   # порт VLESS-трафика (по умолчанию 443)
    environmentFile = config.sops.secrets."x3-ui_env".path;
  };

  # ────────────────────────────────────────────────────────
  # Networking
  # ────────────────────────────────────────────────────────
  networking.hostName = "nixlensk324";
  networking.nameservers = [ "1.1.1.1" ];

  # ────────────────────────────────────────────────────────
  # System packages
  # ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    neovim     
    wget
    git        
    curl
    btop       
    tree
    btrfs-progs 
  ];

  # ────────────────────────────────────────────────────────
  # User
  # ────────────────────────────────────────────────────────
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "qemu" ];
    openssh.authorizedKeys.keys = lib'.sshKeys;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
  
  system.stateVersion = "25.11";
}
