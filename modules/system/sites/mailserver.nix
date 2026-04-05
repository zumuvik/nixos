{ config, lib, pkgs, username, ... }:

let
  domain = "samolensk.ru";
  mailDir = "/var/vmail";
in
{
  # ────────────────────────────────────────────────────────
  # Mail Server — Postfix (SMTP) + Dovecot (IMAP)
  # ────────────────────────────────────────────────────────

  # ── Postfix (SMTP) ─────────────────────────────────────
  services.postfix = {
    enable = true;
    domain = domain;
    hostname = "mail.${domain}";
    mailboxes = {};

    # Виртуальные домены
    virtualMailboxDomains = [ domain ];
    virtualMailboxBase = mailDir;
    virtualMailboxMaps = pkgs.writeText "virtual-mailbox-maps" ''
      admin@${domain}    ${domain}/admin/
      info@${domain}     ${domain}/info/
    '';
    virtualUidMaps = "999";
    virtualGidMaps = "999";

    # TLS
    tlsCert = "/var/lib/acme/mail.${domain}/fullchain.pem";
    tlsKey = "/var/lib/acme/mail.${domain}/key.pem";

    # Настройки
    config = {
      smtpd_tls_security_level = "may";
      smtp_tls_security_level = "may";
      smtpd_sasl_auth_enable = "yes";
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "private/auth";
      smtpd_sasl_security_options = "noanonymous";
      smtpd_sasl_local_domain = "$myhostname";
      smtpd_recipient_restrictions = lib.mkForce "permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination";
      smtpd_relay_restrictions = lib.mkForce "permit_mynetworks, permit_sasl_authenticated, defer_unauth_destination";
      message_size_limit = "26214400"; # 25MB
    };
  };

  # ── Dovecot (IMAP) ─────────────────────────────────────
  services.dovecot2 = {
    enable = true;
    enableImap = true;
    enablePop3 = false;
    enableLmtp = true;
    sslServerCert = "/var/lib/acme/mail.${domain}/fullchain.pem";
    sslServerKey = "/var/lib/acme/mail.${domain}/key.pem";

    # Аутентификация через passwd-файл
    authMechanisms = "plain login";
    mailLocation = "maildir:/var/vmail/%d/%n";

    extraConfig = ''
      # Mail user
      mail_uid = 999
      mail_gid = 999
      first_valid_uid = 999
      last_valid_uid = 999

      # Passwd-file
      passdb {
        driver = passwd-file
        args = scheme=CRYPT username_format=%u /etc/dovecot/users
      }
      userdb {
        driver = passwd-file
        args = username_format=%u /etc/dovecot/users
        default_fields = uid=999 gid=999 home=/var/vmail/%d/%n
      }

      # Postfix SASL
      service auth {
        unix_listener /var/spool/postfix/private/auth {
          mode = 0666
          user = postfix
          group = postfix
        }
      }

      # LMTP для доставки почты
      service lmtp {
        unix_listener /var/spool/postfix/private/dovecot-lmtp {
          mode = 0600
          user = postfix
          group = postfix
        }
      }

      # SSL
      ssl = required
      ssl_min_protocol = TLSv1.2

      # Logging
      log_path = /var/log/dovecot.log
      info_log_path = /var/log/dovecot-info.log
    '';
  };

  # ── Пользователь vmail ─────────────────────────────────
  users.users.vmail = {
    isSystemUser = true;
    group = "vmail";
    home = mailDir;
    createHome = true;
  };
  users.groups.vmail = {
    gid = 999;
  };

  # ── Пользователи почты ─────────────────────────────────
  environment.etc."dovecot/users".text = ''
    admin@${domain}:{PLAIN}admin123:999:999::/var/vmail/${domain}/admin::userdb_mail=maildir:/var/vmail/${domain}/admin
    info@${domain}:{PLAIN}info123:999:999::/var/vmail/${domain}/info::userdb_mail=maildir:/var/vmail/${domain}/info
  '';

  # ── Директории ─────────────────────────────────────────
  systemd.tmpfiles.rules = [
    "d ${mailDir} 0770 vmail vmail -"
    "d ${mailDir}/${domain} 0770 vmail vmail -"
    "d ${mailDir}/${domain}/admin 0770 vmail vmail -"
    "d ${mailDir}/${domain}/info 0770 vmail vmail -"
  ];

  # ── Firewall ───────────────────────────────────────────
  networking.firewall.allowedTCPPorts = [ 25 465 587 993 ];
}
