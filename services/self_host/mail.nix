{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.mail;
  mailjet-user = config.age.secrets."mailjet-user".path;
  mailjet-pass = config.age.secrets."mailjet-pass".path;
in
{
  config = lib.mkIf cfg {
    environment.systemPackages = [
      pkgs.dovecot_pigeonhole
    ];
    users.users.vmail = {
      isSystemUser = true;
      home = "/var/vmail";
      group = "vmail";
      shell = "/run/current-system/sw/bin/nologin";
    };
    users.groups.vmail = { };
    systemd.tmpfiles.rules = [
      "d /run/dovecot 0755 dovecot dovecot - -"
      "d /var/lib/postfix 0755 postfix postfix - -"
      "d /var/lib/postfix/data 0755 postfix postfix - -"
      "d /var/lib/postfix/queue 0755 root root - -"
      "d /var/lib/postfix/queue/maildrop 0730 postfix postdrop - -"
      "d /var/lib/postfix/queue/pid 0755 root root - -"
      "d /var/lib/postfix/queue/private 0750 postfix postfix - -"
      "d /var/lib/postfix/queue/public 0730 postfix postdrop - -"
      "d /var/spool/postfix 0755 postfix postfix - -"
      "d /var/spool/postfix/private 0750 postfix postfix - -"
      "d /var/vmail 0750 vmail vmail - -"
    ];

    services.postfix = {
      enable = true;
      rootAlias = "direction@enium.eu";

      settings = {
        main = {
          myhostname = "mail.enium.eu";
          mydomain = "enium.eu";
          relayhost = [
            "[in-v3.mailjet.com]:587"
          ];

          mydestination = "localhost";
          inet_interfaces = "all";
          inet_protocols = "ipv4";

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
          virtual_alias_maps = "hash:/var/lib/postfix/virtual";

          local_recipient_maps = "";

          smtpd_relay_restrictions = "permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination";
          smtpd_recipient_restrictions = "check_recipient_access hash:/var/lib/postfix/recipient_access";

          smtpd_tls_cert_file = "/var/lib/acme/mail.enium.eu/fullchain.pem";
          smtpd_tls_key_file = "/var/lib/acme/mail.enium.eu/key.pem";

          smtpd_milters = "unix:/run/rspamd/rspamd.sock";
          non_smtpd_milters = "unix:/run/rspamd/rspamd.sock";
          milter_protocol = "6";
          milter_default_action = "accept";
          milter_mail_macros = "i {mail_addr} {client_addr} {client_name} {auth_authen}";
        };
        master."submission" = {
          type = "inet";
          private = false;
          chroot = false;
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
    environment.etc."postfix-recipient_access".text = ''
      no-reply@enium.eu   REJECT 550 Cette adresse n’est pas autorise a recevoir de mail
    '';
    systemd.services.postfix.preStart = lib.mkMerge [
      (lib.mkAfter ''
        umask 077
        echo "[in-v3.mailjet.com]:587 $(cat ${mailjet-pass}):$(cat ${mailjet-pass})" > /var/lib/postfix/sasl_passwd
        chown postfix:postfix /var/lib/postfix/sasl_passwd
        chmod 600 /var/lib/postfix/sasl_passwd
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
      (lib.mkAfter ''
        install -Dm644 /etc/postfix-virtual /var/lib/postfix/virtual
        ${pkgs.postfix}/bin/postmap /var/lib/postfix/virtual
      '')
    ];

    services.dovecot2 = {
      enable = true;
      enableImap = true;
      enableLmtp = true;
      enablePAM = false;

      mailLocation = "maildir:/var/vmail/%d/%n";
      sslServerCert = "/var/lib/acme/mail.enium.eu/fullchain.pem";
      sslServerKey = "/var/lib/acme/mail.enium.eu/key.pem";

      extraConfig = ''
        protocols = imap lmtp
        auth_mechanisms = plain login
        disable_plaintext_auth = yes
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
          # si Postfix attend un autre chemin, on ajustera ici
          unix_listener lmtp {
            mode = 0660
            user = postfix
            group = postfix
          }
        }

        # Sieve exécuté à la livraison (LMTP)
        protocol lmtp {
          mail_plugins = $mail_plugins sieve
        }

        plugin {
          sieve = file:~/.dovecot.sieve
          sieve_dir = ~/sieve
          sieve_after = /var/lib/dovecot/sieve/
        }
      '';
    };

    systemd.services.postfix = {
      after = [
        "rspamd.service"
      ];
      requires = [
        "rspamd.service"
      ];
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
      benjamin@enium.eu:{SHA512-CRYPT}$6$.34vS2JkrmGnioYo$pUF.vN5Q3njn5WRTLdMU5n7vGJdwk64bB/si0vQXFw.ioky4xlHUVocFXC8GI9wkVJNif.2kHvAYEcEtXvU2I0
      deborah@enium.eu:{SHA512-CRYPT}$6$IZ7Dd31uZ4VKzz04$z5IhS25Jve8KsX0GIIXB8GUiPYd3eSuxlDz9RZQHa2tE4hptgtXQVU3av42MIRpaN9GPqG9iM6jiQUwRZ9V39/
    '';
    environment.etc."postfix-vmailbox".text = ''
      raphael@enium.eu enium.eu/raphael/
      benjamin@enium.eu enium.eu/benjamin/
      deborah@enium.eu enium.eu/deborah/
    '';
    environment.etc."postfix-sender_login".text = ''
      raphael@enium.eu raphael@enium.eu
      benjamin@enium.eu benjamin@enium.eu
      deborah@enium.eu deborah@enium.eu

      no-reply@enium.eu raphael@enium.eu, benjamin@enium.eu
      direction@enium.eu raphael@enium.eu, benjamin@enium.eu
      recrutement@enium.eu  raphael@enium.eu, benjamin@enium.eu
      contact@enium.eu raphael@enium.eu, benjamin@enium.eu
    '';
    environment.etc."postfix-virtual".text = ''
      direction@enium.eu raphael@enium.eu, benjamin@enium.eu
      recrutement@enium.eu raphael@enium.eu, benjamin@enium.eu
      contact@enium.eu raphael@enium.eu, benjamin@enium.eu
    '';

    services.rspamd = {
      enable = true;
        extraConfig = ''
          worker "controller" {
            bind_socket = "127.0.0.1:11334";
            password = "admin";
          };

          worker "normal" {
            bind_socket = "127.0.0.1:11333";
          };

          worker "rspamd_proxy" {
            bind_socket = "127.0.0.1:11332";
            milter = yes;
            timeout = 120s;
            upstream "local" {
              self_scan = yes;
            };
          };

          actions {
            reject = 12;
            add_header = 6;
            greylist = 4;
          };

          milter {
            unix_socket = "/run/rspamd/milter.sock";
            unix_permissions = 0660;
            user = "rspamd";
            group = "postfix";
          };

          classifier "bayes" {
            backend = "redis";
            servers = "127.0.0.1:6381";
            autolearn = true;
            min_learns = 200;
            new_schema = true;
            cache = true;

            statfile {
              symbol = "BAYES_HAM";
              spam = false;
            };

            statfile {
              symbol = "BAYES_SPAM";
              spam = true;
            };

            learn_condition = <<EOD
return function(task)
  return true
end
EOD;
        };

        rbl {
          enabled = true;
          rbls = {
            spamhaus = {
              symbol = "RBL_SPAMHAUS";
              rbl = "zen.spamhaus.org";
            };
            barracuda = {
              symbol = "RBL_BARRACUDA";
              rbl = "b.barracudacentral.org";
            };
          };
        };
      '';
    };
    services.redis.servers.rspamd = {
      enable = true;
      port = 6381;
    };
  };
}
