{ config, lib, pkgs, ... }:

{
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
}
