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
    LC_MESSAGES = "ru_RU.UTF-8";
    LC_COLLATE = "ru_RU.UTF-8";
    LC_CTYPE = "ru_RU.UTF-8";
  };

  # Common packages
  environment.systemPackages = with pkgs; [
    git wget gh btop fastfetch curl jq
  ];

  # User Configuration
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  # Nix Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [ "https://cache.nixos.org" ];
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  };

  nix.gc = {
    automatic = true;
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

  # State version should be set at host level, but we have a default
  system.stateVersion = lib.mkDefault "24.11";
}
