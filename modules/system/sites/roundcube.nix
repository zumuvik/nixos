{ config, pkgs, ... }:

let
  domain = "mail.samolensk.ru";
  rootDir = "/var/www/sites/${domain}";
in
{
  # ────────────────────────────────────────────────────────
  # PHP-FPM для Roundcube, MySQL, и Nginx
  # ────────────────────────────────────────────────────────
  services = {
    phpfpm.pools.roundcube = {
      user = "nginx";
      group = "nginx";
      settings = {
        "listen.owner" = "nginx";
        "listen.group" = "nginx";
        "listen.mode" = "0660";
        "pm" = "dynamic";
        "pm.max_children" = 75;
        "pm.start_servers" = 10;
        "pm.min_spare_servers" = 5;
        "pm.max_spare_servers" = 20;
        "pm.max_requests" = 500;
      };
    };

    # ────────────────────────────────────────────────────────
    # MySQL (MariaDB) для Roundcube
    # ────────────────────────────────────────────────────────
    mysql = {
      enable = true;
      package = pkgs.mariadb;
      ensureDatabases = [ "roundcube" ];
      ensureUsers = [
        {
          name = "roundcube";
          ensurePermissions = {
            "roundcube.*" = "ALL PRIVILEGES";
          };
        }
      ];
      initialScript = pkgs.writeText "mysql-init.sql" ''
        CREATE DATABASE IF NOT EXISTS roundcube;
        GRANT ALL PRIVILEGES ON roundcube.* TO 'roundcube'@'localhost' IDENTIFIED BY 'roundcube_password';
        FLUSH PRIVILEGES;
      '';
    };

    # Nginx virtualHost для Roundcube
    nginx.virtualHosts."${domain}" = {
      root = "${rootDir}";
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        index = "index.php";
        tryFiles = "$uri $uri/ /index.php?$args";
      };

      locations."~ \\.php$" = {
        extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.roundcube.socket};
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          include ${pkgs.nginx}/conf/fastcgi_params;
        '';
      };

      extraConfig = ''
        client_max_body_size 25M;
      '';
    };
  };

  # ────────────────────────────────────────────────────────
  # Systemd сервис для инициализации Roundcube
  # ────────────────────────────────────────────────────────
  systemd.services.roundcube-init = {
    description = "Initialize Roundcube";
    after = [ "mysql.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "roundcube-init" ''
        set -euo pipefail

        # Создаём директорию
        mkdir -p ${rootDir}

        # Копируем файлы Roundcube
        if [ ! -f "${rootDir}/index.php" ]; then
          cp -r ${pkgs.roundcube}/* ${rootDir}/
          chown -R nginx:nginx ${rootDir}
        fi

        # Symlink на конфигурацию (environment.etc уже создал /etc/roundcube/config.inc.php)
        mkdir -p ${rootDir}/config
        ln -sf /etc/roundcube/config.inc.php ${rootDir}/config/config.inc.php

        # Инициализируем базу данных SQL-схемой
        if [ -f "${rootDir}/SQL/mysql.initial.sql" ]; then
          ${pkgs.mariadb}/bin/mysql -u root roundcube < "${rootDir}/SQL/mysql.initial.sql" || true
        fi
      '';
    };
  };
}
