{ config, lib, pkgs, ... }:

let
  cfg = config.my.services.playSite;
  siteRoot = "/var/www/sites/play.samolensk.ru";
  # Пакуем файлы сайта из исходников в /etc/nixos/site/
  siteFiles = ../../../../site/play.samolensk.ru;
in
{
  options.my.services.playSite.enable = lib.mkEnableOption "play.samolensk.ru landing page";

  config = lib.mkIf cfg.enable {
    # ────────────────────────────────────────────────────────
    # Создаём директорию и копируем файлы сайта
    # ────────────────────────────────────────────────────────
    systemd.tmpfiles.rules = [
      "d ${siteRoot} 0755 root root -"
      "d ${siteRoot}/assets 0755 root root -"
    ];

    # Копируем сайт при активации системы
    system.activationScripts.playSite = ''
      ${pkgs.coreutils}/bin/cp -rT ${siteFiles} ${siteRoot}
      ${pkgs.coreutils}/bin/chmod -R 755 ${siteRoot}
    '';

    # ────────────────────────────────────────────────────────
    # Nginx virtual host
    # ────────────────────────────────────────────────────────
    services.nginx.virtualHosts."play.samolensk.ru" = {
      enableACME = true;
      forceSSL = true;
      root = siteRoot;

      locations."/" = {
        index = "index.html";
        tryFiles = "$uri $uri/ =404";
        extraConfig = ''
          expires 1h;
        '';
      };

      # Кэширование статики
      locations."~* \\.(css|js|png|jpg|jpeg|webp|gif|ico|svg|woff2?)$" = {
        extraConfig = ''
          expires 7d;
          access_log off;
        '';
      };
    };
  };
}
