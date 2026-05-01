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

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        # ── Первичные креды администратора ──
        # Замени плейсхолдеры перед первым деплоем!
        XUI_USERNAME = "<ADMIN_USER>";
        XUI_PASSWORD = "<ADMIN_PASS>";
      };
      description = "Переменные окружения для контейнера 3X-UI";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Персистентная директория ──
    # Создаётся автоматически systemd-tmpfiles; хранит SQLite-базу панели.
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0700 root root -"
    ];

    # ── Firewall ──
    # Открываем порт VLESS (443) и порт веб-панели.
    networking.firewall.allowedTCPPorts = [
      cfg.vlessPort
      cfg.panelPort
    ];

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

        environment = cfg.environment;

        # Автоматический перезапуск при падении
        restart = "unless-stopped";
      };
    };
  };
}
