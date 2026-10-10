{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.selfhost.backup;

  enabled = {
    nextcloud = config.service.selfhost.nextcloud;
    git = config.service.selfhost.git;
    vault = config.service.selfhost.vault;
  };

  backupRoot = "/var/backup";
  nextcloudDataDir = "/mnt/data/nextcloud";
in
{
  config = lib.mkIf cfg {
    age.secrets = {
      "restic-password" = {
        file = ../../secrets/restic-password.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };

      "restic-s3-env" = {
        file = ../../secrets/restic-s3-env.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    services = {
      postgresqlBackup = lib.mkIf enabled.nextcloud {
        enable = true;
        location = "${backupRoot}/postgresql";
        databases = [ "nextcloud" ];
        startAt = "*-*-* 01:15:00";
      };

      vaultwarden.backupDir = lib.mkIf enabled.vault "${backupRoot}/vaultwarden";

      forgejo.dump = lib.mkIf enabled.git {
        enable = true;
        backupDir = "${backupRoot}/forgejo";
        interval = "*-*-* 04:31:00";
      };

      restic.backups.daily = {
        initialize = true;
        repository = "s3:https://s3.eu-west-par.io.cloud.ovh.net/majestic-gell-mann/backups";
        passwordFile = config.age.secrets."restic-password".path;
        environmentFile = config.age.secrets."restic-s3-env".path;

        paths =
          lib.optional enabled.nextcloud nextcloudDataDir
          ++ lib.optional enabled.nextcloud "${backupRoot}/postgresql"
          ++ lib.optional enabled.vault "${backupRoot}/vaultwarden"
          ++ lib.optional enabled.git "${backupRoot}/forgejo";

        exclude = [
          "**/*.log"
          "**/*.tmp"
          "**/cache/**"
          "**/lost+found/**"
          "**/tmp/**"
        ];

        timerConfig = {
          OnCalendar = "*-*-* 05:30:00";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };

        pruneOpts = [
          "--keep-daily 3"
          "--keep-weekly 2"
          "--keep-monthly 3"
          "--prune"
          "--compression=auto"
        ];
      };
    };
  };
}
