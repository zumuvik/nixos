{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.x3-ui;
in
{
  options.my.services.x3-ui = {
    enable = lib.mkEnableOption "3X-UI — веб-панель управления Xray/VLESS";

    panelPort = lib.mkOption {
      type = lib.types.port;
      default = 2053;
      description = "TCP-порт веб-панели 3X-UI";
    };

    extraPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [];
      example = [ 8443 ];
      description = ''
        Дополнительные TCP-порты для firewall (напр. порты inbound-ов VLESS/Trojan).
        Добавь сюда порт, когда создаёшь новый inbound в панели.
      '';
    };

    extraPortRanges = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          from = lib.mkOption { type = lib.types.port; description = "Начальный порт диапазона"; };
          to = lib.mkOption { type = lib.types.port; description = "Конечный порт диапазона"; };
        };
      });
      default = [];
      example = [ { from = 2000; to = 3000; } ];
      description = ''
        Диапазоны TCP и UDP портов для firewall.
        Удобно, если не хочется каждый раз пересобирать конфиг при добавлении inbound-а.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/3x-ui";
      description = "Директория для персистентного хранения БД и конфигов панели";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/wings-n/3x-ui:latest";
      description = "Docker-образ 3X-UI";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Путь к env-файлу с секретами (XUI_USERNAME, XUI_PASSWORD).
        Обычно это config.sops.secrets."x3-ui_env".path.
      '';
    };

    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "vpn.samolensk.ru";
      description = ''
        Домен для nginx reverse proxy с ACME SSL.
        Если null — панель доступна напрямую по порту.
      '';
    };

    subscriptionPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "Порт подписок, если он отличается от основного порта панели (например, 2042).";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Персистентные директории ──
    # Создаются автоматически systemd-tmpfiles; хранят SQLite-базу панели и сертификаты.
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0700 root root -"
      "d ${cfg.dataDir}/db 0700 root root -"
      "d ${cfg.dataDir}/cert 0700 root root -"
    ];

    # ── Firewall ──
    # panelPort — порт веб-панели, extraPorts — порты inbound-ов (VLESS, Trojan и т.д.).
    # При наличии domain дополнительно 80/443 для nginx + ACME.
    networking.firewall.allowedTCPPorts =
      [ cfg.panelPort ] ++ cfg.extraPorts
      ++ lib.optionals (cfg.domain != null) [ 80 443 ];

    networking.firewall.allowedTCPPortRanges = cfg.extraPortRanges;
    networking.firewall.allowedUDPPortRanges = cfg.extraPortRanges;

    # ── Nginx reverse proxy ──
    # Проксируем панель через HTTPS с автоматическим Let's Encrypt.
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
          proxyPass = "http://127.0.0.1:${toString cfg.panelPort}";
          proxyWebsockets = true;
        };
        locations."/sub" = lib.mkIf (cfg.subscriptionPort != null) {
          proxyPass = "http://127.0.0.1:${toString cfg.subscriptionPort}";
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
    # Используем встроенный в NixOS oci-containers вместо Arion для
    # точного соответствия официальному docker-compose.yml.
    virtualisation.oci-containers.containers."3xui_app" = {
      image = cfg.image;
      
      environment = {
        XUI_ENABLE_FAIL2BAN = "true";
      };

      environmentFiles = lib.mkIf (cfg.environmentFile != null) [
        cfg.environmentFile
      ];

      volumes = [
        "${cfg.dataDir}/db:/etc/x-ui/"
        "${cfg.dataDir}/cert:/root/cert/"
      ];

      extraOptions = [
        "--network=host"
        "--tty"
      ];
    };
  };
}
