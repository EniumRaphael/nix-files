{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.nextcloud;
  nextcloud-admin-pass = config.age.secrets."nextcloud-admin-pass".path;
  nextcloud-database = config.age.secrets."nextcloud-database".path;
  nextcloudLogo = pkgs.fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/6/60/Nextcloud_Logo.svg";
    name = "nextcloud.svg";
    sha256 = "sha256-hL51zJkFxUys1CoM8yUxiH8BDw111wh3Qv7eTLm+XYo=";
  };
  dataDir = "/mnt/data/nextcloud";
in
{
  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      php
    ];
    users = {
      groups.datausers = { };
      users.nextcloud.extraGroups = [
        "datausers"
      ];
    };

    age.secrets = {
      "nextcloud-database" = {
        file = ../../secrets/nextcloud-database.age;
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0400";
      };
      "nextcloud-admin-pass" = {
        file = ../../secrets/nextcloud-admin-pass.age;
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0400";
      };
      "nextcloud-oidc-secret" = {
        file = ../../secrets/nextcloud-oidc-secret.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };
    };

    systemd = {
      tmpfiles.rules = [
        "d /mnt/data 2770 root datausers -"
        "d /mnt/data/nextcloud 0750 nextcloud nextcloud -"
        "d /mnt/data/nextcloud/config 0750 nextcloud nextcloud -"
        "d /mnt/data/nextcloud/data 0750 nextcloud nextcloud -"
      ];
      services."nextcloud-setup" = {
        requires = [
          "postgresql.service"
        ];
        after = [
          "postgresql.service"
        ];
      };
    };

    services = {
      postgresql = {
        enable = true;
        ensureDatabases = [
          "nextcloud"
        ];
        ensureUsers = [
          {
            name = "nextcloud";
            ensureDBOwnership = true;
          }
        ];
      };
      postgresqlBackup = {
        enable = true;
        location = "/data/backup/nextclouddb";
        databases = [
          "nextcloud"
        ];
        startAt = "*-*-* 23:15:00";
      };
      redis.servers.nextcloud = {
        enable = true;
        user = "nextcloud";
        group = "nextcloud";
        unixSocket = "/run/redis-nextcloud/redis.sock";
        unixSocketPerm = 770;
      };
      nextcloud = {
        enable = true;
        https = true;
        package = pkgs.nextcloud33;
        hostName = "nextcloud.enium.eu";
        datadir = dataDir;
        config = {
          adminpassFile = nextcloud-admin-pass;
          adminuser = "OwnedByTheEniumTeam";
          dbtype = "pgsql";
          dbname = "nextcloud";
          dbhost = "localhost";
          dbuser = "nextcloud";
          dbpassFile = nextcloud-database;
        };
        extraApps = {
          inherit (pkgs.nextcloud33Packages.apps) calendar contacts;
          user_oidc = pkgs.fetchNextcloudApp {
            appName = "user_oidc";
            appVersion = "0.8.2";
            license = "agpl3Plus";
            url = "https://github.com/nextcloud-releases/user_oidc/releases/download/v8.10.1/user_oidc-v8.10.1.tar.gz";
            sha256 = "sha256-Sc7R/hkjAvRUC4aUOLbMucoNabcXt27XB1pwqlz2Zv0=";
          };
        };
        settings = {
          trusted_domains = [
            "192.168.1.254"
            "nextcloud.enium.eu"
          ];
          default_phone_region = "FR";
        };
        configureRedis = true;
      };
      kanidm.provision.systems.oauth2 = {
        nextcloud = {
          present = true;
          displayName = "Nextcloud";
          imageFile = nextcloudLogo;
          originUrl = "https://nextcloud.enium.eu/apps/user_oidc/code";
          originLanding = "https://nextcloud.enium.eu/login";
          basicSecretFile = config.age.secrets.nextcloud-oidc-secret.path;
          public = false;
          enableLocalhostRedirects = false;
          allowInsecureClientDisablePkce = false;
          preferShortUsername = false;
          claimMaps = {
            groups = {
              joinType = "array";
              valuesByGroup = {
                nextcloud_admins = [ "admin" ];
              };
            };
          };
          scopeMaps = {
            nextcloud_admins = [
              "openid"
              "profile"
              "email"
              "groups"
            ];
            nextcloud_user = [
              "openid"
              "profile"
              "email"
              "groups"
            ];
          };
        };
      };
      nginx.virtualHosts."nextcloud.enium.eu" = {
        enableACME = true;
        forceSSL = true;
        locations."~ \.php$".extraConfig = ''
          fastcgi_pass unix:/run/phpfpm-nextcloud.sock;
        '';
      };
    };
    security.apparmor.policies.nextcloud = {
      state = "enforce";
      profile = ''
        #include <tunables/global>
        profile nextcloud /run/current-system/sw/bin/php-fpm {
          #include <abstractions/base>
          #include <abstractions/nameservice>
          #include <abstractions/php>
          /mnt/data/nextcloud/**     rw,
          /etc/nextcloud/**         r,
          /var/log/nextcloud/**     rw,
          network unix stream,
          deny /home/**             rw,
          deny /root/**             rw,
          deny /etc/shadow          r,
          deny network inet  stream,  # Pas d'accès internet direct
          deny network inet6 stream,
        }
      '';
    };
  };
}
