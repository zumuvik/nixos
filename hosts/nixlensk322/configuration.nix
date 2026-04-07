{ config, lib, pkgs, inputs, username, ... }:

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
  time.timeZone = "Europe/Moscow";

  networking.networkmanager.enable = true;
  networking.networkmanager.settings.main.dns = "none";
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 3389 ];
  networking.firewall.allowedUDPPorts = [ ];

  # ────────────────────────────────────────────────────────
  # Keyboard layout
  # ────────────────────────────────────────────────────────
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  # ────────────────────────────────────────────────────────
  # User
  # ────────────────────────────────────────────────────────
  programs.zsh.enable = true;
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm" "qemu" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEP3GKg44+5QOaTUj7kHMO9x4sMhShdVuK4NR1yMtleQ zumuvik@nixlensk323"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9RWNYncLPCFQm4vcL0Ln3f8CG14g/JtUc42fPBjyJN laptop"
    ];
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
    git
    wget
    gh
    wireguard-tools
    zip
    unzip
    unrar
    xrandr
    brightnessctl
    grim
    slurp
    wl-clipboard
    mako
    swww
    btop
    opencode
    fastfetch
    networkmanagerapplet
    pavucontrol
    nix-search
  ];

  # ────────────────────────────────────────────────────────
  # Locale
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
  # Boot
  # ────────────────────────────────────────────────────────
  boot.kernelModules = [ "kvm" "kvm-amd" ];
  boot.kernelParams = [ "idle=nomwait" ];

  boot.loader.grub = {
    enable = true;
    device = lib.mkForce "/dev/nvme0n1";
    efiSupport = lib.mkForce false;
    useOSProber = lib.mkForce true;
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
