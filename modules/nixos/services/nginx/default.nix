{ config, lib, pkgs, ... }:

let
  cfg = config.my.services.nginx;
in
{
  options.my.services.nginx.enable = lib.mkEnableOption "Nginx web server";

  config = lib.mkIf cfg.enable {
    # ────────────────────────────────────────────────────────
    # Nginx — веб-сервер для сайтов
    # ────────────────────────────────────────────────────────
    services.nginx = {
      enable = true;

      # Оптимизация
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      # Общие настройки
      appendConfig = ''
        worker_processes auto;
        worker_rlimit_nofile 65535;
      '';

      # Логирование
      logError = "stderr info";
      appendHttpConfig = ''
        access_log /var/log/nginx/access.log;

        # Security headers
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options SAMEORIGIN;
        add_header X-XSS-Protection "1; mode=block";
        add_header Referrer-Policy strict-origin-when-cross-origin;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

        # Блокируем доступ по IP и неизвестным доменам
        server {
          listen 80 default_server;
          listen [::]:80 default_server;
          listen 443 ssl default_server;
          listen [::]:443 ssl default_server;
          server_name _;
          ssl_certificate /var/lib/acme/mail.samolensk.ru/fullchain.pem;
          ssl_certificate_key /var/lib/acme/mail.samolensk.ru/key.pem;
          return 444;
        }
      '';
    };

    # ────────────────────────────────────────────────────────
    # ACME (Let's Encrypt) — автоматические SSL сертификаты
    # ────────────────────────────────────────────────────────
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "admin@samolensk.ru";
        dnsProvider = null; # Используем HTTP-01 challenge
      };
    };

    # Директория для сайтов
    systemd.tmpfiles.rules = [
      "d /var/www 0755 root root -"
      "d /var/www/sites 0755 root root -"
      "d /var/www/sites/mail.samolensk.ru 0755 root root -"
    ];

    # Открываем порты для HTTP/HTTPS
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
