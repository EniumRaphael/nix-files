{ config, pkgs, lib, ... }:

let
  cfg = config.service.selfhost.mail;
  mailjetSecrets = import ../../.mailjetcred.nix;
in
{
  config = lib.mkIf cfg {
    users.users.vmail = {
      isSystemUser = true;
      home = "/var/vmail";
      group = "vmail";
      shell = "/run/current-system/sw/bin/nologin";
    };
    users.groups.vmail = {};
    systemd.tmpfiles.rules = [
      "d /var/vmail 0750 vmail vmail - -"
      "d /var/spool/postfix 0755 postfix postfix - -"
      "d /var/spool/postfix/private 0750 postfix postfix - -"
      "d /run/dovecot 0755 dovecot dovecot - -"
    ];

    security.acme.certs."mail.enium.eu" = {
      group = "nginx";
      reloadServices = [ "postfix.service" "dovecot.service" ];
    };
    users.groups.nginx.members = [ "postfix" "dovecot" ];

    services.postfix = {
      enable = true;
      rootAlias = "raphael@enium.eu";

      settings = {
        main = {
          myhostname = "mail.enium.eu";
          mydomain   = "enium.eu";
          relayhost  = [
            "[in-v3.mailjet.com]:587"
          ];

          mydestination = "localhost";
          inet_interfaces = "all";
          inet_protocols  = "ipv4";

          smtp_sasl_auth_enable = "yes";
          smtp_sasl_password_maps = "hash:/var/lib/postfix/sasl_passwd";
          smtp_sasl_security_options = "noanonymous";
          smtpd_sasl_type = "dovecot";
          smtpd_sasl_path = "/run/dovecot/auth-client";

          smtp_tls_security_level = "may";
          smtp_tls_CAfile = "/etc/ssl/certs/ca-certificates.crt";
          smtp_tls_session_cache_database = "btree:/var/lib/postfix/smtp_scache";
          
          virtual_mailbox_domains = "enium.eu";
          virtual_transport = "lmtp:unix:/run/dovecot/lmtp";
          virtual_mailbox_maps = "hash:/var/lib/postfix/vmailbox";

          local_recipient_maps = "";

          smtpd_relay_restrictions = "permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination";
          smtpd_recipient_restrictions = "check_recipient_access hash:/var/lib/postfix/recipient_access";

          smtpd_tls_cert_file = "/var/lib/acme/mail.enium.eu/fullchain.pem";
          smtpd_tls_key_file  = "/var/lib/acme/mail.enium.eu/key.pem";

          smtpd_milters = "unix:/run/rspamd/rspamd-milter.sock";
          non_smtpd_milters = "unix:/run/rspamd/rspamd-milter.sock";
          milter_protocol = "6";
          milter_default_action = "accept";
        };
        master."submission" = {
          type = "inet";
          private = false;
          chroot  = false;
          command = "smtpd";
          args = [
            "-o" "smtpd_recipient_restrictions=permit_sasl_authenticated,reject"
            "-o" "smtpd_sasl_auth_enable=yes"
            "-o" "smtpd_sasl_security_options=noanonymous"
            "-o" "smtpd_sender_login_maps=hash:/var/lib/postfix/sender_login"
            "-o" "smtpd_sender_restrictions=reject_sender_login_mismatch"
            "-o" "smtpd_tls_auth_only=yes"
            "-o" "smtpd_tls_security_level=encrypt"
            "-o" "syslog_name=postfix/submission"
          ];
        };
      };
    };
    environment.etc."postfix-sender_login".text = ''
      raphael@enium.eu   raphael@enium.eu
      no-reply@enium.eu   raphael@enium.eu
    '';
    environment.etc."postfix-sasl_passwd" = {
      text = "[in-v3.mailjet.com]:587 ${mailjetSecrets.smtpUser}:${mailjetSecrets.smtpPass}\n";
      mode = "0600";
    };
    environment.etc."postfix-recipient_access".text = ''
      no-reply@enium.eu   REJECT 550 Cette adresse n’est pas autorise a recevoir de mail
    '';
    systemd.services.postfix.preStart = lib.mkMerge [
      (lib.mkAfter ''
        install -Dm600 /etc/postfix-sasl_passwd /var/lib/postfix/sasl_passwd
        ${pkgs.postfix}/bin/postmap /var/lib/postfix/sasl_passwd
      '')
      (lib.mkAfter ''
        install -Dm644 /etc/postfix-recipient_access /var/lib/postfix/recipient_access
        ${pkgs.postfix}/bin/postmap /var/lib/postfix/recipient_access
      '')
      (lib.mkAfter ''
        install -Dm644 /etc/postfix-sender_login /var/lib/postfix/sender_login
        ${pkgs.postfix}/bin/postmap /var/lib/postfix/sender_login
      '')
      (lib.mkAfter ''
        install -Dm644 /etc/postfix-vmailbox /var/lib/postfix/vmailbox
        ${pkgs.postfix}/bin/postmap /var/lib/postfix/vmailbox
      '')
    ];

    services.dovecot2 = {
      enable = true;
      enableImap = true;
      mailLocation = "maildir:/var/vmail/%d/%n";
      sslServerCert = "/var/lib/acme/mail.enium.eu/fullchain.pem";
      sslServerKey  = "/var/lib/acme/mail.enium.eu/key.pem";
      extraConfig = ''
        disable_plaintext_auth = yes
        auth_mechanisms = plain login
        ssl = required
        protocols = imap lmtp
        base_dir = /run/dovecot

        userdb {
          driver = static
          args = uid=vmail gid=vmail home=/var/vmail/%d/%n
        }
        passdb {
          driver = passwd-file
          args = scheme=SHA512-CRYPT username_format=%u /etc/dovecot/users
        }

        service imap-login {
          inet_listener imap {
            port = 0
          }
          inet_listener imaps {
            port = 993
            ssl = yes
          }
        }

        service auth {
          unix_listener auth-client {
            mode = 0660
            user = postfix
            group = postfix
          }
        }
        service lmtp {
          unix_listener lmtp {
            mode = 0660
            user = postfix
            group = postfix
          }
        }

        protocol lmtp {
        }
      '';
    };

    systemd.services.dovecot.after = [
      "postfix-setup.service"
      "postfix.service"
    ];
    systemd.services.dovecot.requires = [
      "postfix-setup.service"
    ];

    # doveadm pw -s SHA512-CRYPT
    environment.etc."dovecot/users".text = ''
      raphael@enium.eu:{SHA512-CRYPT}$6$rIsn6/dLJ6MbITx5$vMo82dgkQZoV8BQIaO6Bs9J86ZjgcJ.LqMuIqnXVfuBRgZOqY/YiURBUOcS1P2wAo5h4TCFkKExfcjjX1reUU.
    '';
    environment.etc."postfix-vmailbox".text = ''
      raphael@enium.eu   enium.eu/raphael/
    '';

    services.nginx.virtualHosts."mail.enium.eu" = {
      forceSSL = true;
      enableACME = true;
    };

    services.rspamd.enable = true;

    services.roundcube = {
      enable = true;
      hostName = "mail.enium.eu";
      extraConfig = ''
        $config['smtp_host'] = "tls://mail.enium.eu";
        $config['smtp_port'] = 587;
        $config['smtp_user'] = "%u";
        $config['smtp_pass'] = "%p";
        $config['smtp_auth_type'] = "LOGIN";
        $config['imap_host'] = "ssl://mail.enium.eu";
        $config['default_port'] = 993;
        $config['username_domain'] = 'enium.eu';
      '';
    };
  };
}
