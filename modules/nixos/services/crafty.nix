{ config, lib, pkgs, ... }:

let
  cfg = config.my.services.crafty;
in
{
  options.my.services.crafty = {
    enable = lib.mkEnableOption "Crafty Controller (Minecraft Server Manager)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8443;
      description = "TCP port for Crafty Web UI (default is 8443 for HTTPS)";
    };

    mcPort = lib.mkOption {
      type = lib.types.port;
      default = 25565;
      description = "Default Minecraft Java port";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/crafty";
      description = "Directory for Crafty data (servers, logs, config)";
    };

    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "crafty.samolensk.ru";
      description = "Domain for Nginx reverse proxy. if null, access via port.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create persistent directories with correct permissions for Crafty (UID 1000)
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 1000 1000 -"
      "d ${cfg.dataDir}/backups 0755 1000 1000 -"
      "d ${cfg.dataDir}/logs 0755 1000 1000 -"
      "d ${cfg.dataDir}/servers 0755 1000 1000 -"
      "d ${cfg.dataDir}/config 0755 1000 1000 -"
      "d ${cfg.dataDir}/import 0755 1000 1000 -"
    ];

    # Firewall
    networking.firewall.allowedTCPPorts = [ cfg.mcPort 8123 19132 ]
      ++ lib.optionals (cfg.domain != null) [ 80 443 ];
    networking.firewall.allowedUDPPorts = [ cfg.mcPort 19132 ];
    
    # Open standard range for Minecraft servers (25500-25600)
    networking.firewall.allowedTCPPortRanges = [ { from = 25500; to = 25600; } ];
    networking.firewall.allowedUDPPortRanges = [ { from = 25500; to = 25600; } ];

    # OCI Container
    virtualisation.oci-containers.containers.crafty = {
      image = "registry.gitlab.com/crafty-controller/crafty-4:latest";
      # Note: when using --network=host, 'ports' is ignored by podman/docker
      volumes = [
        "${cfg.dataDir}/backups:/crafty/backups"
        "${cfg.dataDir}/logs:/crafty/logs"
        "${cfg.dataDir}/servers:/crafty/servers"
        "${cfg.dataDir}/config:/crafty/app/config"
        "${cfg.dataDir}/import:/crafty/import"
      ];
      environment = {
        TZ = "Europe/Moscow";
      };
      extraOptions = [
        "--network=host"
      ];
    };

    # Nginx Reverse Proxy
    services.nginx = lib.mkIf (cfg.domain != null) {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8000";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
    # ACME
    security.acme = lib.mkIf (cfg.domain != null) {
      acceptTerms = true;
      defaults.email = "admin@samolensk.ru";
    };
  };
}
