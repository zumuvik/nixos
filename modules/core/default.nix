{ lib, pkgs, username, ... }:

{
  # ────────────────────────────────────────────────────────
  # Core System Settings (Shared by all hosts)
  # ────────────────────────────────────────────────────────
  
  networking.networkmanager.enable = lib.mkDefault true;
  networking.firewall.enable = lib.mkDefault true;

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
    LC_MESSAGES = "ru_RU.UTF-8";
    LC_COLLATE = "ru_RU.UTF-8";
    LC_CTYPE = "ru_RU.UTF-8";
  };

  # Common packages
  environment.systemPackages = with pkgs; [
    git wget gh btop curl jq
  ];

  # User Configuration
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "render" ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  # Nix Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [ 
      "https://cache.nixos.org"
      "https://cache.garnix.io"
      "https://attic.xuyh0120.win/lantian"
    ];
    trusted-public-keys = [ 
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" 
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
    trusted-users = [ "root" "@wheel" ];
  };

  nix.gc = {
    automatic = false;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  # Console & Locales
  console.useXkbConfig = true;

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

   # Base boot loader settings (Overridden by profiles/hosts)
   boot.loader = {
     systemd-boot.enable = lib.mkDefault false;
     efi.canTouchEfiVariables = true;
     grub = {
       enable = true;
       device = lib.mkDefault "nodev";
       efiSupport = lib.mkDefault true;
       useOSProber = false;
     };
   };

   # Global defaults for common services
   networking.firewall.checkReversePath = "loose";

   # Nix-LD for non-nixos binaries
   programs.nix-ld.enable = true;

   # Home Manager global settings
   home-manager.backupFileExtension = "backup";

   # System State Version
   system.stateVersion = lib.mkDefault "24.11";

   # NH (Nix Helper)
   my.services.nh.enable = true;
}
