{ config, lib, pkgs, username, ... }:

let
  domain = "samolensk.ru";
  sslCertDir = config.security.acme.certs."mail.${domain}".directory;
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

    config = {
      smtpd_tls_chain_files = [ "${sslCertDir}/fullchain.pem" "${sslCertDir}/key.pem" ];
      smtpd_tls_security_level = "may";
      smtp_tls_security_level = "may";
      smtpd_sasl_auth_enable = "yes";
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "/var/spool/postfix/auth";
      smtpd_sasl_security_options = "noanonymous";
      smtpd_recipient_restrictions = "permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination";
      smtpd_relay_restrictions = "permit_mynetworks, permit_sasl_authenticated, defer_unauth_destination";
      message_size_limit = 26214400; # 25MB

      # LMTP delivery via Dovecot
      virtual_transport = "lmtp:unix:/var/spool/postfix/dovecot-lmtp";
      virtual_mailbox_domains = domain;
      virtual_mailbox_maps = pkgs.writeText "virtual-mailbox-maps" ''
        admin@${domain}    ${domain}/admin/
        info@${domain}     ${domain}/info/
      '';
      virtual_mailbox_base = "/var/vmail";
      virtual_uid_maps = "static:999";
      virtual_gid_maps = "static:999";
    };
  };

  # ── Dovecot (IMAP) ─────────────────────────────────────
  services.dovecot2 = {
    enable = true;
    enablePAM = false;
    enableImap = true;
    enablePop3 = false;
    enableLmtp = true;
    createMailUser = true;
    mailUser = "vmail";
    mailGroup = "vmail";
    mailLocation = "maildir:~/Maildir";
    sslServerCert = "${sslCertDir}/fullchain.pem";
    sslServerKey = "${sslCertDir}/key.pem";

    mailboxes = {
      Drafts = { auto = "create"; specialUse = "Drafts"; };
      Junk = { auto = "create"; specialUse = "Junk"; };
      Trash = { auto = "create"; specialUse = "Trash"; };
      Sent = { auto = "create"; specialUse = "Sent"; };
    };

    extraConfig = ''
      auth_username_format = %Lu
      auth_mechanisms = plain login

      passdb {
        driver = passwd-file
        args = scheme=PLAIN username_format=%u /etc/dovecot/users
      }

      userdb {
        driver = passwd-file
        args = username_format=%u /etc/dovecot/users
        default_fields = uid=vmail gid=vmail home=/var/vmail/%d/%n
      }

      service auth {
        unix_listener /var/spool/postfix/auth {
          mode = 0600
          user = postfix
          group = postfix
        }
      }

      service lmtp {
        unix_listener /var/spool/postfix/dovecot-lmtp {
          mode = 0600
          user = postfix
          group = postfix
        }
      }

      ssl = required
      ssl_min_protocol = TLSv1.2
    '';
  };

  # ── Пользователи почты ─────────────────────────────────
  environment.etc."dovecot/users".text = ''
    admin@${domain}:{PLAIN}admin123
    info@${domain}:{PLAIN}info123
  '';

  # ── Директории ─────────────────────────────────────────
  systemd.tmpfiles.rules = [
    "d /var/spool/postfix 0755 root root -"
    "d /var/spool/postfix/private 0700 postfix postfix -"
  ];

  # ── Firewall ───────────────────────────────────────────
  networking.firewall.allowedTCPPorts = [ 25 465 587 993 ];
}
