{ config, lib, pkgs, ... }:

let
  cfg = config.my.services.wingsv-panel;
in
{
  options.my.services.wingsv-panel = {
    enable = lib.mkEnableOption "WingsV Panel";

    listenAddr = lib.mkOption {
      type = lib.types.str;
      default = ":8080";
      description = "Address to listen on";
    };

    publicBaseUrl = lib.mkOption {
      type = lib.types.str;
      description = "Public URL for the panel";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/wingsv-panel";
      description = "Directory for WingsV Panel data";
    };
    
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for the panel";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to environment file with secrets";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 wingsv-panel wingsv-panel -"
    ];

    users.users.wingsv-panel = {
      isSystemUser = true;
      group = "wingsv-panel";
      home = cfg.dataDir;
    };
    users.groups.wingsv-panel = {};

    virtualisation.oci-containers.containers.wingsv-panel = {
      image = "ghcr.io/wings-n/wingsv-panel:latest";
      ports = [ "${toString cfg.port}:${toString cfg.port}" ];
      volumes = [
        "${cfg.dataDir}:/app"
      ];
      environment = {
        LISTEN_ADDR = cfg.listenAddr;
        PUBLIC_BASE_URL = cfg.publicBaseUrl;
        DB_PATH = "/app/wingsv.db";
      };
      environmentFiles = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
