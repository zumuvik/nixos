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

    # Копируем сайт и SSL сертификаты при активации системы
    system.activationScripts.playSite = ''
      ${pkgs.coreutils}/bin/cp -rT ${siteFiles} ${siteRoot}
      ${pkgs.coreutils}/bin/chmod -R 755 ${siteRoot}

      # Настройка SSL-сертификатов Cloudflare Origin
      ${pkgs.coreutils}/bin/mkdir -p /var/lib/ssl
      ${pkgs.coreutils}/bin/cp -f /etc/nixos/secrets/play.samolensk.ru.cert.pem /var/lib/ssl/play.samolensk.ru.cert.pem
      ${pkgs.coreutils}/bin/cp -f /etc/nixos/secrets/play.samolensk.ru.key.pem /var/lib/ssl/play.samolensk.ru.key.pem
      ${pkgs.coreutils}/bin/chmod 400 /var/lib/ssl/play.samolensk.ru.cert.pem /var/lib/ssl/play.samolensk.ru.key.pem
      ${pkgs.coreutils}/bin/chown nginx:nginx /var/lib/ssl/play.samolensk.ru.cert.pem /var/lib/ssl/play.samolensk.ru.key.pem
    '';

    # ────────────────────────────────────────────────────────
    # Nginx virtual host
    # ────────────────────────────────────────────────────────
    services.nginx.virtualHosts."play.samolensk.ru" = {
      forceSSL = true;
      sslCertificate = "/var/lib/ssl/play.samolensk.ru.cert.pem";
      sslCertificateKey = "/var/lib/ssl/play.samolensk.ru.key.pem";
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
