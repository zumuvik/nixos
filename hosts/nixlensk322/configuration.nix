{ config, lib, pkgs, inputs, username, hostName, lib', ... }:

let
  cloudflareApiToken = lib.fileContents ./.secret;
in

{
  imports = [
    ../../modules/system/cloudflare-dns-sync.nix
  ];

  services.cloudflare-dns-sync = {
    enable = true;
    apiToken = cloudflareApiToken;
    checkInterval = "hourly";
    domains = [
      { zone = "samolensk.ru"; records = [ "mail" "@" ]; }
    ];
  };

  # ────────────────────────────────────────────────────────
  # Networking & Hostname
  # ────────────────────────────────────────────────────────
  networking.hostName = "nixlensk322";

  networking.networkmanager.settings.main.dns = "none";
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
  networking.firewall.allowedTCPPorts = [ 80 443 3389 ];

  # ────────────────────────────────────────────────────────
  # User (server-specific: qemu + SSH keys)
  # ────────────────────────────────────────────────────────
  users.users.${username} = {
    extraGroups = [ "qemu" ];
    openssh.authorizedKeys.keys = lib'.sshKeys;
  };

  # ────────────────────────────────────────────────────────
  # sudo без пароля (server-specific: podman)
  # ────────────────────────────────────────────────────────
  security.sudo.extraRules = [
    {
      users = [ "${username}" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl restart podman-wg-easy.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl status podman-wg-easy.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/journalctl -u podman-wg-easy.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/podman";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # ────────────────────────────────────────────────────────
  # System packages (host-specific)
  # ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    zip
    unzip
    unrar
    xrandr
    opencode
    nix-search
  ];

  # ────────────────────────────────────────────────────────
  # Locale (server: en_US)
  # ────────────────────────────────────────────────────────
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";
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
  };

  # ────────────────────────────────────────────────────────
  # Boot (non-EFI)
  # ────────────────────────────────────────────────────────
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "idle=nomwait" ];

  boot.loader.grub = {
    enable = lib.mkDefault true;
    device = lib.mkForce "/dev/nvme0n1";
    efiSupport = lib.mkForce false;
  };

  # ────────────────────────────────────────────────────────
  # VNC (wayvnc для Wayland/Hyprland)
  # ────────────────────────────────────────────────────────
  # TODO: enable when nixpkgs has services.wayvnc
  # services.wayvnc.enable = true;
  # services.wayvnc.address = "0.0.0.0";
  # services.wayvnc.port = 5900;
  # services.wayvnc.openFirewall = true;
}
