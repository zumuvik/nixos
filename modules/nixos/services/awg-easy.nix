{ pkgs, config, lib, ... }:

let
  cfg = config.my.services.awg-easy;
  wgSubnet = "10.9.0.0/24"; # Другая подсеть, чтобы не конфликтовать с wg-easy
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
              "awg-easy-config:/etc/amneziawg"
              "/lib/modules:/lib/modules:ro"
            ];

            # Используем тот же секрет или отдельный, если нужно
            env_file = [ config.sops.secrets."wg_easy_env".path ];

            environment = {
              WG_HOST = "awg.samolensk.ru";
              WG_PORT = "51822";
              WEBUI_HOST = "0.0.0.0";
              WEBUI_PORT = "51823";
              WG_DEFAULT_ADDRESS = "10.9.x.x";

              WG_DEFAULT_DNS = "1.1.1.1";
              WG_AUTH_BYPASS_LOCALHOST = "true";
            };
          };
        };
        docker-compose.volumes.awg-easy-config = {};
      };
    };

    # NAT и Firewall для AWG
    networking.nftables.enable = true;
    networking.nftables.ruleset = ''
      table ip nat {
        chain postrouting {
          type nat hook postrouting priority 100; policy accept;
          ip saddr ${wgSubnet} oifname "${cfg.externalInterface}" masquerade
        }
      }
      table ip filter {
        chain forward {
          type filter hook forward priority 0; policy accept;
          iifname "awg0" accept
          oifname "awg0" accept
        }
        chain input {
          type filter hook input priority 0; policy accept;
          udp dport 51822 accept
        }
      }
    '';

    networking.firewall.allowedUDPPorts = [ 51822 ];
    networking.firewall.allowedTCPPorts = [ 51823 ];

    # Nginx Reverse Proxy
    services.nginx.virtualHosts."awg.samolensk.ru" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:51823";
        proxyWebsockets = true;
      };
    };
  };
}
