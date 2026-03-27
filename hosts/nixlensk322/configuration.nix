{ config, pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # ────────────────────────────────────────────────
  # Boot
  # ────────────────────────────────────────────────
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  boot.kernelModules = [ "kvm" "kvm-amd" "iptable_nat"
    "iptable_filter"
    "ip_tables"
    "nf_nat"
    "nf_conntrack"
    "nf_defrag_ipv4" "tun"  ];
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  boot.extraModprobeConfig = ''
    alias char-major-10-200 tun
  '';

  # ────────────────────────────────────────────────
  # Networking — basics
  # ────────────────────────────────────────────────
  networking.hostName = "nixlensk322";
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Убираем приветствие при входе
      set fish_greeting ""

      # Настройка монохромной темы (белый, серый, черный)
      set -g fish_color_command white --bold
      set -g fish_color_param normal
      set -g fish_color_autosuggestion purple
      set -g fish_color_comment 555
      set -g fish_color_quote ccc
      set -g fish_color_end white
      set -g fish_color_error ff5555
    '';

    shellAliases = {
      # Ваши привычные сокращения
      ls = "ls --color=auto";
      ll = "ls -la";
      edit = "micro";
      # Быстрый переход к конфигу NixOS
      conf = "micro /etc/nixos/configuration.nix";
      rebuild = "sudo nixos-rebuild switch";
    };
  };

  networking.wireguard.enable = true;

  # Используем NetworkManager только для WAN-интерфейса (удобно для тестов/Wi-Fi)
  networking.networkmanager.enable = true;

  # Отключаем управление enp8s0 и br0 через NetworkManager
  networking.networkmanager.unmanaged = [ "enp8s0" "br0" "interface-name:enp8s0" "interface-name:br0" ];

  # WAN — DHCP
  networking.interfaces.enp6s0.useDHCP = true;

  # LAN — bridge + статический IP на мосту
  networking.bridges = {
    br0.interfaces = [ "enp8s0" ];
  };

  networking.interfaces = {
    enp8s0.ipv4.addresses = [ ];          # убираем любой IP с физического порта
    br0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.3.1";
        prefixLength = 24;
      }];
    };
  };

  # NAT
  networking.nat = {
    enable = true;
    externalInterface = "enp6s0";
    internalInterfaces = [ "br0" ];
  };

  # ────────────────────────────────────────────────
  # dnsmasq — DHCP + DNS для LAN
  # ────────────────────────────────────────────────
  services.dnsmasq = {
    enable = true;

    # resolveLocalQueries = false;          # ← раскомментируй, если systemd-resolved мешает

    settings = {
      interface = "br0";
      except-interface = "enp6s0 lo";

      listen-address = "192.168.3.1";

      bind-interfaces = true;               # ← обязательно при нескольких интерфейсах
      dhcp-authoritative = true;            # ← ускоряет выдачу адресов, меньше глюков

      dhcp-range = "192.168.3.100,192.168.3.200,12h";

      dhcp-option = [
        "3,192.168.3.1"                     # gateway
        "6,1.1.1.1,8.8.8.8"                 # dns
      ];

      domain = "local";
      expand-hosts = true;

      server = [ "1.1.1.1" "8.8.8.8" ];
      no-resolv = false;                    # используем upstream dns из server=

      log-dhcp = true;
      log-queries = true;
    };
  };

  # ────────────────────────────────────────────────
  # Firewall
  # ────────────────────────────────────────────────
  networking.firewall = {
    enable = true;

    trustedInterfaces = [ "br0" "tun0" "docker0" ];

    allowedTCPPorts = [
      22      # ssh
      25      # smtp (если нужно)
      80 443  # http/https (caddy?)
      2017 8000 8123 8443
      25565   # minecraft?
    ];

    allowedUDPPorts = [
      67 68           # DHCP
      51820           # wireguard?
      24454           # ?
    ];

    # Дополнительные правила для DHCP (nftables-style)
    extraInputRules = ''
      iifname "br0" udp dport { 67, 68 } accept comment "DHCP server incoming"
      iifname "br0" udp sport { 67, 68 } accept comment "DHCP client replies"
    '';

    extraForwardRules = ''
      iifname "br0" oifname "enp6s0" accept comment "LAN -> WAN"
      iifname "enp6s0" oifname "br0" ct state { established, related } accept comment "WAN -> LAN return"
    '';
  };

  # ────────────────────────────────────────────────
  # Locale, timezone
  # ────────────────────────────────────────────────
  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

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

  # ────────────────────────────────────────────────
  # User & sudo
  # ────────────────────────────────────────────────
  users.users.zumuvik = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "zumuvik";
    extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" ];
    packages = with pkgs; [ fastfetch vim git dig htop curl wget tcpdump ];
  };

  security.sudo.extraRules = [{
    users = [ "zumuvik" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];

  # ────────────────────────────────────────────────
  # Virtualization & containers
  # ────────────────────────────────────────────────
  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };

  # ────────────────────────────────────────────────
  # System packages
  # ────────────────────────────────────────────────
  programs.virt-manager.enable = true;
  environment.systemPackages = with pkgs; [
    vim git curl wget htop neofetch fastfetch btop micro gh
    xray sing-box nftables iproute2
    docker docker-compose
    caddy libvirt      # Сами бинарники virsh
        qemu    kitty.terminfo      # Эмулятор
        bridge-utils
    wireguard-tools
    samba nfs-utils
    virt-viewer   # вместо virt-manager, если GUI не нужен
  ];

  # ────────────────────────────────────────────────
  # Graphics / Remote Desktop
  # ────────────────────────────────────────────────
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm.enable = true;
  };

  services.xrdp = {
    enable = true;
    defaultWindowManager = "xfce4-session";
  };

  # ────────────────────────────────────────────────
  # NAT модули ядра
  # ────────────────────────────────────────────────



  # ────────────────────────────────────────────────
  # SSH
  # ────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # ────────────────────────────────────────────────
  # NixOS version
  # ────────────────────────────────────────────────
  system.stateVersion = "25.11";   # ← не меняй без причины
}
