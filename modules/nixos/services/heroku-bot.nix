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
  };

  config = lib.mkIf cfg.enable {
    # Создаем директорию для данных
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
    ];

    virtualisation.oci-containers.containers.heroku-bot = {
      image = "localhost/heroku-bot:latest"; # Образ собран локально
      ports = [
        "${toString cfg.port}:8080"
      ];
      volumes = [
        "${cfg.dataDir}:/data/Heroku/session" # Маппим сессию
      ];
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
