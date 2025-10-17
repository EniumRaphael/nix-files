{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.sso;
  envFile = config.age.secrets."authentik-env".path;
  envDst = "/run/authentik/env";
in
  {
  config = lib.mkIf cfg {
    systemd.tmpfiles.rules = [
      "d /run/authentik 0750 authentik authentik - -"
    ];

    systemd.services.authentik-env = {
      description = "Prepare Authentik environment file";
      before = [
        "authentik.service"
        "authentik-migrate.service"
        "authentik-worker.service"
      ];
      wantedBy = [
        "authentik.service"
        "authentik-migrate.service"
        "authentik-worker.service"
      ];
      after = [
        "systemd-sysusers.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/install -D -m0400 ${envFile} ${envDst}";
        ExecStartPost = "${pkgs.coreutils}/bin/chown authentik:authentik ${envDst}";
      };
    };

    systemd.services.authentik = {
      after = [ "authentik-env.service" "postgresql.service" "redis-authentik.service" ];
      requires = [ "authentik-env.service" "postgresql.service" "redis-authentik.service" ];
    };

    services = {
      authentik = {
        enable = true;
        environmentFile = envDst;
        settings = {
          AUTHENTIK_LISTEN__HTTP = "127.0.0.1:9000";
          AUTHENTIK_POSTGRESQL__HOST = "/run/postgresql";
          AUTHENTIK_POSTGRESQL__USER = "authentik";
          AUTHENTIK_POSTGRESQL__NAME = "authentik";
          AUTHENTIK_REDIS__HOST = "127.0.0.1";
          AUTHENTIK_REDIS__DB = 0;
          AUTHENTIK_REDIS__PORT = 6380;
        };
      };
      redis.servers.authentik.port = lib.mkForce 6380;
      postgresql = {
        enable = true;
        ensureDatabases = [
          "authentik"
        ];
        ensureUsers = [
          {
            name = "authentik";
            ensureDBOwnership = true;
          }
        ];
        initialScript = pkgs.writeText "init-authentik-db.sql" ''
          ALTER USER authentik WITH PASSWORD '$(grep AUTHENTIK_POSTGRESQL__PASSWORD ${envFile} | cut -d= -f2)';
        '';
      };
      nginx = {
        virtualHosts."auth.enium.eu" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9000";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
