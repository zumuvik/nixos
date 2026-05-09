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
  sops.secrets."cloudflare_env" = {};

  # ────────────────────────────────────────────────────────
  # Services
  # ────────────────────────────────────────────────────────

  my.services.heroku-bot = {
    enable = true;
    port = 8080;
    # domain = "heroku.samolensk.ru";
  };

  my.services.crafty = {
    enable = true;
    domain = "crafty.samolensk.ru";
  };

  my.services.cloudflare-sync = {
    enable = true;
    checkInterval = "hourly";
    domains = [
      { zone = "samolensk.ru"; records = [ "vpn" "crafty" "smp" ]; }
    ];
  };

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

  networking.nat = {
    enable = true;
    externalInterface = "ens18";
    internalInterfaces = [ "ve-valera-box" ];
  };

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

  # ────────────────────────────────────────────────────────
  # Containers
  # ────────────────────────────────────────────────────────
  containers.valera-box = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    forwardPorts = [
      { protocol = "tcp"; hostPort = 2222; containerPort = 22; }
      { protocol = "tcp"; hostPort = 8081; containerPort = 80; }
    ];

    config = { config, pkgs, ... }: {
      boot.isContainer = true;
      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
        settings.KbdInteractiveAuthentication = false;
        settings.PermitRootLogin = "no";
      };

      services.mediawiki = {
        enable = true;
        name = "Просто вики";
        passwordFile = "/var/keys/mediawiki-admin-pass";
        url = "http://45.13.237.210:8081";
        httpd.virtualHost = {
          hostName = "45.13.237.210";
          adminAddr = "admin@localhost";
        };
        extraConfig = ''
          $wgMetaNamespace = "Служебка";
        '';
      };

      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.registry.nixpkgs.flake = inputs.nixpkgs;
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      users.users.mascot_valera = {
        isNormalUser = true;
        description = "Mascot Valera";
        openssh.authorizedKeys.keys = lib'.extraKeys.mascot_valera;
        extraGroups = [ ];
      };

      networking.firewall.allowedTCPPorts = [ 22 ];
      system.stateVersion = "24.11";
      
      environment.systemPackages = with pkgs; [
        neovim wget git curl btop
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 2222 8081 56092 25565 ];
  networking.firewall.allowedUDPPorts = [ 25565 24454 ];
  
  system.stateVersion = "25.11";
}
