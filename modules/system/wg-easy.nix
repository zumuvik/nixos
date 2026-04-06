{ config, pkgs, lib, ... }:

let
  extIf = "enp6s0";
  wgSubnet = "10.8.0.0/24";
in

{
  # ────────────────────────────────────────────────────────
  # WireGuard Easy — VPN сервер с веб-интерфейсом
  # Работает через podman (без Docker)
  # ────────────────────────────────────────────────────────

  # Kernel modules для NAT и iptables
  boot.kernelModules = [
    "wireguard"
    "ip_tables"
    "iptable_filter"
    "iptable_nat"
    "ipt_MASQUERADE"
    "nf_nat"
    "nf_conntrack"
    "nf_defrag_ipv4"
    "xt_conntrack"
    "xt_addrtype"
    "xt_mark"
  ];

  # IP forwarding для маршрутизации трафика клиентов
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.src_valid_mark" = 1;
  };

  # ────────────────────────────────────────────────────────
  # Podman (container runtime)
  # ────────────────────────────────────────────────────────
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;

  # ────────────────────────────────────────────────────────
  # Создание podman сети для wg-easy
  # ────────────────────────────────────────────────────────
  systemd.services.podman-wg-network-create = {
    description = "Create wg Podman network";
    before = [ "podman-wg-easy.service" ];
    requires = [ "podman.service" ];
    wantedBy = [ "podman-wg-easy.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.podman}/bin/podman network rm wg 2>/dev/null || true
      ${pkgs.podman}/bin/podman network create \
        --driver bridge \
        --subnet 10.42.42.0/24 \
        wg 2>/dev/null || true
    '';
  };

  # ────────────────────────────────────────────────────────
  # wg-easy контейнер
  # ────────────────────────────────────────────────────────
  virtualisation.oci-containers.containers."wg-easy" = {
    image = "ghcr.io/wg-easy/wg-easy:15";
    autoStart = true;

    volumes = [
      "wg-easy-config:/etc/wireguard"
    ];

    environment = {
      WG_HOST = "vpn.samolensk.ru";
      WG_PORT = "44321";
      WEBUI_HOST = "0.0.0.0";
      WEBUI_PORT = "51821";

      # Отключаем iptables внутри контейнера (NAT на хосте)
      IPTABLES_BACKEND = "nft";

      # Unattended setup — создаёт пользователя при первом запуске
      INIT_ENABLED = "true";
      INIT_USERNAME = "admin";
      INIT_PASSWORD = "zxczxczxc";
    };

    networks = [ "wg" ];

    ports = [
      "44321:44321/udp"
      "51821:51821/tcp"
    ];

    extraOptions = [
      "--privileged=true"
      "--ip=10.42.42.42"
      "--cap-add=NET_ADMIN"
      "--cap-add=SYS_MODULE"
      "--cap-add=NET_RAW"
      "--sysctl=net.ipv4.ip_forward=1"
      "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
    ];
  };

  # ────────────────────────────────────────────────────────
  # NAT на хосте (вместо iptables внутри контейнера)
  # ────────────────────────────────────────────────────────
  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table ip nat {
      chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        ip saddr ${wgSubnet} oifname "${extIf}" masquerade
      }
    }
    table ip filter {
      chain forward {
        type filter hook forward priority 0; policy accept;
        iifname "wg0" accept
        oifname "wg0" accept
      }
      chain input {
        type filter hook input priority 0; policy accept;
        udp dport 44321 accept
      }
    }
  '';

  # Хранилище конфигурации WireGuard
  systemd.tmpfiles.rules = [
    "d /var/lib/containers/storage/volumes/wg-easy-config 0755 root root -"
  ];

  # ────────────────────────────────────────────────────────
  # Firewall
  # ────────────────────────────────────────────────────────
  networking.firewall.allowedUDPPorts = [ 44321 ];
  networking.firewall.allowedTCPPorts = [ 51821 ];
}
