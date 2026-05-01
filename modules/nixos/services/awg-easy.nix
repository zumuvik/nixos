{ pkgs, config, lib, ... }:

let
  cfg = config.my.services.awg-easy;

  # Заглушки для iptables — AmneziaWG Easy (как и wg-easy) может требовать iptables в контейнере
  iptablesStub = pkgs.pkgsMusl.stdenv.mkDerivation {
    name = "awg-iptables-stub";
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
  options.my.services.awg-easy = {
    enable = lib.mkEnableOption "AmneziaWG Easy VPN server";
    externalInterface = lib.mkOption {
      type = lib.types.str;
      default = "enp6s0";
    };
  };

  config = lib.mkIf cfg.enable {
    # Kernel modules для NAT и AmneziaWG
    boot.kernelModules = [
      "amneziawg"
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

    boot.extraModulePackages = [
      config.boot.kernelPackages.amneziawg
    ];

    # IP forwarding для маршрутизации трафика клиентов
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = lib.mkForce 1;
      "net.ipv4.conf.all.src_valid_mark" = lib.mkForce 1;
    };

    # Arion (Docker Compose for Nix)
    virtualisation.arion = {
      backend = "docker";
      projects.awg-easy.settings = {
        project.name = "awg-easy";
        services.awg-easy = {
          service = {
            image = "ghcr.io/gennadykataev/awg-easy:latest";
            container_name = "awg-easy";
            network_mode = "host";
            capabilities = {
              NET_ADMIN = true;
              SYS_MODULE = true;
              NET_RAW = true;
            };
            restart = "always";

            volumes = [
              "/var/lib/awg-easy:/etc/amnezia/amneziawg"
              "/var/lib/awg-easy:/etc/wireguard"
              "/lib/modules:/lib/modules:ro"
            ];

            # Используем тот же секрет или отдельный, если нужно
            env_file = [ config.sops.secrets."wg_easy_env".path ];

            environment = {
              WG_HOST = "awg.samolensk.ru";
              WG_PORT = "51820";
              WG_DEFAULT_ADDRESS = "10.9.0.x";
              WG_DEFAULT_DNS = "1.1.1.1";
              WG_MTU = "1420";
              WEBUI_HOST = "0.0.0.0";
              PORT = "51821";
              WEBUI_PORT = "51821";
              WG_AUTH_BYPASS_LOCALHOST = "true";
              LANG = "ru";
            };
          };
        };

      };
    };

    # Хранилище конфигурации AmneziaWG
    systemd.tmpfiles.rules = [
      "d /var/lib/awg-easy 0700 root root -"
    ];

    # Ensure docker is enabled
    virtualisation.docker.enable = true;

    # NAT и Firewall для AWG
    networking.nftables.enable = true;
    networking.nftables.ruleset = lib.mkAfter ''
      table ip awg_nat {
        chain postrouting {
          type nat hook postrouting priority 100; policy accept;
          ip saddr 10.9.0.0/24 oifname "${cfg.externalInterface}" masquerade
        }
      }
      table ip awg_filter {
        chain forward {
          type filter hook forward priority 0; policy accept;
          iifname "wg0" accept
          oifname "wg0" accept
        }
        chain input {
          type filter hook input priority 0; policy accept;
          udp dport 51820 accept
        }
      }
    '';

    # Nginx Reverse Proxy
    services.nginx.virtualHosts."awg.samolensk.ru" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:51821";
        proxyWebsockets = true;
      };
    };
  };
}
