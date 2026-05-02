{ config, pkgs, lib, ... }:

let
  cfg = config.my.services.mailserver;
  domain = "samolensk.ru";
  sslCertDir = config.security.acme.certs."mail.${domain}".directory;
in
{
  options.my.services.mailserver.enable = lib.mkEnableOption "Mail Server (SMTP/IMAP)";

  config = lib.mkIf cfg.enable {
    # ────────────────────────────────────────────────────────
    # Mail Server — Postfix (SMTP) + Dovecot (IMAP)
    # ────────────────────────────────────────────────────────

    # ── Postfix (SMTP) ─────────────────────────────────────
    services.postfix = {
      enable = true;
      enableSubmission = true;
      enableSubmissions = true;

      settings.main = {
        mydomain = domain;
        myhostname = "mail.${domain}";
        smtpd_tls_chain_files = [ "${sslCertDir}/key.pem" "${sslCertDir}/fullchain.pem" ];
        smtpd_tls_security_level = "may";
        smtp_tls_security_level = "may";
        smtpd_sasl_auth_enable = "yes";
        smtpd_sasl_type = "dovecot";
        smtpd_sasl_path = "/var/spool/postfix/auth";
        smtpd_sasl_security_options = "noanonymous";
        smtpd_recipient_restrictions = "permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination";
        smtpd_relay_restrictions = "permit_mynetworks, permit_sasl_authenticated, defer_unauth_destination";
        message_size_limit = 26214400; # 25MB

        virtual_transport = "lmtp:unix:/var/spool/postfix/dovecot-lmtp";
        virtual_mailbox_domains = domain;
        virtual_mailbox_maps = "hash:/etc/postfix/virtual_mailbox_maps";
        virtual_mailbox_base = "/var/vmail";
        virtual_uid_maps = "static:vmail";
        virtual_gid_maps = "static:vmail";
      };

      mapFiles = {
        virtual_mailbox_maps = pkgs.writeText "virtual-mailbox-maps" ''
          admin@${domain}    ${domain}/admin/
          info@${domain}     ${domain}/info/
        '';
      };
    };

    # ── Dovecot (IMAP) ─────────────────────────────────────
    services.dovecot2 = {
      enable = true;
      package = pkgs.dovecot;
      enablePAM = false;

      settings = {
        dovecot_config_version = config.services.dovecot2.package.version;
        dovecot_storage_version = config.services.dovecot2.package.version;
        protocols = "imap lmtp";
        mail_location = "maildir:~/Maildir";
        mail_uid = "vmail";
        mail_gid = "vmail";
        ssl = "required";
        ssl_cert = "<${sslCertDir}/fullchain.pem";
        ssl_key = "<${sslCertDir}/key.pem";
        ssl_min_protocol = "TLSv1.2";
        disable_plaintext_auth = "yes";
        auth_username_format = "%Lu";
        auth_mechanisms = [ "plain" "login" ];

        "namespace inbox" = {
          inbox = "yes";
        };

        "passdb" = {
          driver = "passwd-file";
          args = "scheme=PLAIN username_format=%u ${config.sops.secrets."mail_users".path}";
        };

        "userdb" = {
          driver = "passwd-file";
          args = "username_format=%u ${config.sops.secrets."mail_users".path}";
          override_fields = "uid=vmail gid=vmail home=/var/vmail/%d/%n";
        };

        "service auth" = {
          unix_listener."/var/spool/postfix/auth" = {
            mode = "0600";
            user = "postfix";
            group = "postfix";
          };
        };

        "service lmtp" = {
          unix_listener."/var/spool/postfix/dovecot-lmtp" = {
            mode = "0600";
            user = "postfix";
            group = "postfix";
          };
        };
      };
    };

    users.users.vmail = {
      isNormalUser = false;
      group = "vmail";
      home = "/var/vmail";
    };

    users.groups.vmail = {};

    # ── Директории ─────────────────────────────────────────
    systemd.tmpfiles.rules = [
      "d /var/spool/postfix 0755 root root -"
      "d /var/spool/postfix/private 0700 postfix postfix -"
      "d /var/vmail 0770 vmail vmail -"
      "d /var/vmail/${domain} 0770 vmail vmail -"
      "d /var/vmail/${domain}/admin 0770 vmail vmail -"
      "d /var/vmail/${domain}/admin/Maildir 0770 vmail vmail -"
      "d /var/vmail/${domain}/info 0770 vmail vmail -"
      "d /var/vmail/${domain}/info/Maildir 0770 vmail vmail -"
    ];

    # ── Firewall ───────────────────────────────────────────
    networking.firewall.allowedTCPPorts = [ 25 465 587 993 ];
  };
}
