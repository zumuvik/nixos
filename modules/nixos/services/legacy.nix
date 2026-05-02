{ config, lib, pkgs, ... }:

let
  cfg = config.my.services.legacy;
in
{
  options.my.services.legacy = {
    enable = lib.mkEnableOption "Legacy Userbot (Telegram)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "TCP-порт для веб-интерфейса Legacy";
    };

    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "legacy.samolensk.ru";
      description = ''
        Домен для nginx reverse proxy с ACME SSL.
        Если null — веб-интерфейс доступен напрямую по порту.
      '';
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "crayz310/legacy:latest";
      description = "Docker-образ Legacy";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/legacy";
      description = "Директория для персистентного хранения данных";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Персистентные директории ──
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0700 root root -"
    ];

    # ── Firewall ──
    networking.firewall.allowedTCPPorts =
      [ cfg.port ]
      ++ lib.optionals (cfg.domain != null) [ 80 443 ];

    # ── Nginx reverse proxy ──
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
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    # ── ACME ──
    security.acme = lib.mkIf (cfg.domain != null) {
      acceptTerms = true;
      defaults.email = "admin@samolensk.ru";
    };

    # ── OCI Containers (Docker/Podman) ──
    virtualisation.oci-containers.containers."legacy_userbot" = {
      image = cfg.image;
      ports = [
        "${if cfg.domain != null then "127.0.0.1" else "0.0.0.0"}:${toString cfg.port}:8080"
      ];
      volumes = [
        "${cfg.dataDir}:/data"
      ];
      extraOptions = [
        "--interactive"
        "--tty"
      ];
    };
  };
}
