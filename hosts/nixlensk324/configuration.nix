{ config, lib, pkgs, username, lib', ... }:

{
  my.profiles.server.enable = true;

  # ────────────────────────────────────────────────────────
  # Boot & Filesystems
  # ────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" ];

  # ────────────────────────────────────────────────────────
  # Sops-nix (управление секретами)
  # ────────────────────────────────────────────────────────
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

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

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes"; 
      PasswordAuthentication = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
  
  system.stateVersion = "25.11";
}
