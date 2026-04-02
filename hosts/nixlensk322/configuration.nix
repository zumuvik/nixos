{ config, lib, pkgs, username, ... }:

{
  # ────────────────────────────────────────────────────────
  # Networking & Hostname
  # ────────────────────────────────────────────────────────
  networking.hostName = "nixlensk322";
  time.timeZone = "Europe/Moscow";

  # WAN — DHCP
  networking.interfaces.enp6s0.useDHCP = true;

  # NetworkManager — отключаем управление для bridge
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "enp8s0" "br0" "interface-name:enp8s0" "interface-name:br0" ];

  programs.zsh.enable = true;

  # ────────────────────────────────────────────────────────
  # User
  # ────────────────────────────────────────────────────────
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "${username}";
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEP3GKg44+5QOaTUj7kHMO9x4sMhShdVuK4NR1yMtleQ zumuvik@nixlensk323"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9RWNYncLPCFQm4vcL0Ln3f8CG14g/JtUc42fPBjyJN laptop"
    ];
  };

  services.openssh.settings.PasswordAuthentication = false;

  # ────────────────────────────────────────────────────────
  # sudo без пароля
  # ────────────────────────────────────────────────────────
  security.sudo.extraRules = [{
    users = [ "${username}" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];

  # ────────────────────────────────────────────────────────
  # System packages (server-specific)
  # ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    vim git curl wget htop fastfetch btop micro gh
    xray sing-box nftables iproute2
    caddy
    bridge-utils
    wireguard-tools
    samba nfs-utils
    virt-viewer
  ];

  # ────────────────────────────────────────────────────────
  # virt-manager
  # ────────────────────────────────────────────────────────
  programs.virt-manager.enable = true;

  # ────────────────────────────────────────────────────────
  # Locale
  # ────────────────────────────────────────────────────────
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";
  services.xserver.xkb.layout = "us";
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

  boot.loader.grub = {
    enable = true;
    device = lib.mkForce "/dev/nvme0n1";
    useOSProber = lib.mkForce true;
  };
}
