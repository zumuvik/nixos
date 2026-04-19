{ lib, pkgs, username, lib', ... }:


{
  my.profiles.server.enable = true;
  my.services.wg-easy.enable = true;
  my.services.roundcube.enable = true;
  my.services.mailserver.enable = true;

  imports = [
  ];

  my.services.cloudflare-sync = {
    enable = true;
    checkInterval = "hourly";
    domains = [
      { zone = "samolensk.ru"; records = [ "mail" "@" ]; }
    ];
  };

  # ────────────────────────────────────────────────────────
  # Networking & Hostname
  # ────────────────────────────────────────────────────────
  networking = {
    hostName = "nixlensk322";
    networkmanager.settings.main.dns = "none";
    nameservers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
    firewall.allowedTCPPorts = [ 80 443 ];
  };

  # ────────────────────────────────────────────────────────
  # Sops-nix (управление секретами)
  # ────────────────────────────────────────────────────────
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.secrets."cloudflare_env" = {};
  sops.secrets."git_sync_env" = {};
  sops.secrets."wg_easy_env" = {};
  sops.secrets."roundcube_db_pass" = {
    owner = "nginx";
    group = "nginx";
  };
  sops.secrets."mail_users" = {
    owner = "vmail";
    group = "vmail";
  };

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
/*
        {
          command = "/run/current-system/sw/bin/podman";
          options = [ "NOPASSWD" ];
        }
*/
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
    nix-search
  ];



  # ────────────────────────────────────────────────────────
  # Boot (non-EFI)
  # ────────────────────────────────────────────────────────
  boot.kernelModules = [ "kvm-amd" ];

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
