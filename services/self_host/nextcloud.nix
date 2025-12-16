{ config, pkgs, lib, ... }:

let
  cfg = config.service.selfhost.nextcloud;
  nextcloud-admin-pass = config.age.secrets."nextcloud-admin-pass".path;
  nextcloud-database = config.age.secrets."nextcloud-database".path;
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
        package = pkgs.nextcloud32;
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
        settings = {
          trusted_domains = [
            "192.168.1.254"
            "nextcloud.enium.eu"
          ];
          default_phone_region = "FR";
        };
        configureRedis = true;
      };
      nginx.virtualHosts."nextcloud.enium.eu" = {
        enableACME = true;
        forceSSL = true;
        locations."~ \.php$".extraConfig = ''
          fastcgi_pass unix:/run/phpfpm-nextcloud.sock;
        '';
      };
    };
  };
}
