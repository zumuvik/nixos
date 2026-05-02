{ config, lib, pkgs, ... }:

let
  cfg = config.my.services.heroku-bot;
in
{
  options.my.services.heroku-bot = {
    enable = lib.mkEnableOption "Heroku Userbot (Telegram)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "TCP-порт для веб-интерфейса Heroku Bot";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/heroku-bot";
      description = "Директория для хранения сессий и данных бота";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Открыть порт в firewall для веб-интерфейса";
    };
  };

  config = lib.mkIf cfg.enable {
    # Создаем директорию для данных
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
    ];

    virtualisation.oci-containers.containers.heroku-bot = {
      image = "localhost/heroku-bot:latest";
      ports = [
        "${toString cfg.port}:8080"
      ];
      volumes = [
        "${cfg.dataDir}:/data/Heroku/session"
      ];
    };

    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [ cfg.port ];
  };
}
