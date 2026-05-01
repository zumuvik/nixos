{ pkgs, config, lib, ... }:

let
  cfg = config.my.services.wg-easy;
  extIf = "enp6s0";
  wgSubnet = "10.8.0.0/24";

  # Заглушки для iptables — контейнер v15 требует legacy iptables,
  # но на ядре 6.18+ модуль iptable_nat отсутствует.
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
  options.my.services.wg-easy = {
    enable = lib.mkEnableOption "WireGuard Easy VPN server";
    externalInterface = lib.mkOption {
      type = lib.types.str;
      default = "enp6s0";
      description = "The external network interface for NAT masquerade.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ────────────────────────────────────────────────────────
    # WireGuard Easy — VPN сервер с веб-интерфейсом
    # Работает через Arion (Docker)
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

    # Arion (Docker Compose for Nix)
    virtualisation.arion = {
      backend = "docker"; # Or "podman" if you prefer, but docker is common for arion
      projects.wg-easy.settings = {
        project.name = "wg-easy";
        services.wg-easy = {
          service = {
            image = "ghcr.io/wg-easy/wg-easy:15";
            container_name = "wg-easy";
            network_mode = "host";
            capabilities = {
              NET_ADMIN = true;
              SYS_MODULE = true;
              NET_RAW = true;
            };
            restart = "always";
            
            volumes = [
              "wg-easy-config:/etc/wireguard"
              "${iptablesStub}/bin/iptables:/usr/sbin/iptables:ro"
              "${iptablesStub}/bin/iptables:/usr/sbin/ip6tables:ro"
            ];

            # Arion supports environmentFiles
            env_file = [ config.sops.secrets."wg_easy_env".path ];

            environment = {
              WG_HOST = "wg-easy.samolensk.ru";
              WG_PORT = "44321";
              WEBUI_HOST = "10.8.0.1";
              WEBUI_PORT = "51821";
              WG_AUTH_BYPASS_LOCALHOST = "true";
              INIT_ENABLED = "true";
              INIT_USERNAME = "admin";
            };
          };
        };
        # Named volume definition if needed, though host paths are often simpler
        # Arion creates docker-compose.yml, so we can define volumes there
        docker-compose.volumes.wg-easy-config = {};
      };
    };

    # Ensure docker/podman is enabled for Arion
    virtualisation.docker.enable = true;

    # NAT на хосте через nftables (вместо iptables в контейнере)
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

    # Firewall
    networking.firewall.allowedUDPPorts = [ 44321 ];
    networking.firewall.allowedTCPPorts = [ 51821 ]; # Temporary for direct access

    # Nginx Reverse Proxy for Web UI
    services.nginx.virtualHosts."wg-easy.samolensk.ru" = {
      enableACME = true;
      forceSSL = false; # Temporarily disable to fix 526 error during challenge
      locations."/" = {
        proxyPass = "http://127.0.0.1:51821";
        proxyWebsockets = true;
      };
    };
  };
}
