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

    vlessPort = lib.mkOption {
      type = lib.types.port;
      default = 443;
      description = "TCP-порт для входящего VLESS-трафика";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/3x-ui";
      description = "Директория для персистентного хранения БД и конфигов панели";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/mhsanaei/3x-ui:latest";
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
  };

  config = lib.mkIf cfg.enable {
    # ── Персистентная директория ──
    # Создаётся автоматически systemd-tmpfiles; хранит SQLite-базу панели.
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0700 root root -"
    ];

    # ── Firewall ──
    # Открываем порт VLESS-трафика и порт панели.
    # При наличии domain дополнительно открываем 80/443 для nginx + ACME.
    networking.firewall.allowedTCPPorts =
      [ cfg.vlessPort cfg.panelPort ]
      ++ lib.optionals (cfg.domain != null) [ 80 443 ];

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
      };
    };

    # ── ACME ──
    security.acme = lib.mkIf (cfg.domain != null) {
      acceptTerms = true;
      defaults.email = "admin@samolensk.ru";
    };

    # ── Arion: бэкенд ──
    # Используем Podman через сокет (не требует Docker-демона).
    virtualisation.arion.backend = "podman-socket";

    # ── Arion (docker-compose) проект ──
    virtualisation.arion.projects.x3-ui.settings = {
      services.x3-ui.service = {
        # Образ 3X-UI (форк MHSanaei)
        image = cfg.image;

        # host-сеть: контейнер использует сетевой стек хоста напрямую.
        # Это исключает NAT-оверхед Docker и позволяет панели
        # корректно определять реальные IP-адреса клиентов.
        network_mode = "host";

        # Том: прокидываем локальную директорию в /etc/x-ui внутри контейнера,
        # чтобы база данных SQLite (пользователи, inbound-ы, настройки)
        # переживала перезапуски и nixos-rebuild.
        volumes = [
          "${cfg.dataDir}:/etc/x-ui"
        ];

        # env_file: секреты (XUI_USERNAME, XUI_PASSWORD) читаются из
        # зашифрованного sops-файла, а не хранятся в Nix-коде.
        env_file = lib.mkIf (cfg.environmentFile != null) [
          cfg.environmentFile
        ];

        # Автоматический перезапуск при падении
        restart = "unless-stopped";
      };
    };
  };
}
