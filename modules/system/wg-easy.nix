{ config, pkgs, lib, ... }:

let
  extIf = "enp6s0";
  wgSubnet = "10.8.0.0/24";

  # Заглушки для iptables — контейнер v15 требует legacy iptables,
  # но на ядре 6.18+ модуль iptable_nat отсутствует.
  # NAT настраивается через nftables на хосте.
  # Статический бинарник через musl (в контейнере нет bash).
  iptablesStub = pkgs.pkgsMusl.stdenv.mkDerivation {
    name = "iptables-stub";
    src = pkgs.writeText "main.c" "int main(void) { return 0; }";
    dontUnpack = true;
    buildPhase = ''
      $CC $src -o iptables -static
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp iptables $out/bin/iptables
      ln -s $out/bin/iptables $out/bin/ip6tables
    '';
  };
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
  # wg-easy контейнер — host network (прямой доступ к сети хоста)
  # ────────────────────────────────────────────────────────
  virtualisation.oci-containers.containers."wg-easy" = {
    image = "ghcr.io/wg-easy/wg-easy:15";
    autoStart = true;

    volumes = [
      "wg-easy-config:/etc/wireguard"
      "${iptablesStub}:/usr/sbin/iptables:ro"
      "${iptablesStub}:/usr/sbin/ip6tables:ro"
    ];

    environment = {
      WG_HOST = "vpn.samolensk.ru";
      WG_PORT = "44321";
      WEBUI_HOST = "0.0.0.0";
      WEBUI_PORT = "51821";

      # Unattended setup — создаёт пользователя при первом запуске
      INIT_ENABLED = "true";
      INIT_USERNAME = "admin";
      INIT_PASSWORD = "zxczxczxc";
    };

    extraOptions = [
      "--network=host"
      "--privileged"
      "--cap-add=NET_ADMIN"
      "--cap-add=SYS_MODULE"
      "--cap-add=NET_RAW"
    ];
  };

  # ────────────────────────────────────────────────────────
  # NAT на хосте через nftables (вместо iptables в контейнере)
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
