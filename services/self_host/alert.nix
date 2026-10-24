{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.service.selfhost.backup;

  enabled = {
    nextcloud = config.service.selfhost.nextcloud;
    git = config.service.selfhost.git;
    vault = config.service.selfhost.vault;
  };

  mailFrom = "alert@infra.parodi.tech";
  mailTo = "root@parodi.tech";

  maxAgeHours = 26;
  stampFile = "/var/lib/backup-alert/backup.success";

  notify = pkgs.writeShellScript "backup-notify" ''
    subject="$1"
    body="$2"
    {
      echo "From: Infra Alert <${mailFrom}>"
      echo "To: ${mailTo}"
      echo "Subject: $subject"
      echo "Content-Type: text/plain; charset=UTF-8"
      echo
      echo "$body"
    } | /run/wrappers/bin/sendmail -t
  '';
in
{
  config = lib.mkIf cfg {
    age.secrets."alert-mail-password" = {
      file = ../../secrets/alert-mail-password.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };

    programs.msmtp = {
      enable = true;
      setSendmail = true;
      defaults = {
        auth = true;
        tls = true;
        tls_starttls = false;
        logfile = "/var/log/msmtp.log";
      };
      accounts.default = {
        host = "smtp.migadu.com";
        port = 465;
        from = mailFrom;
        user = mailFrom;
        passwordeval = "cat ${config.age.secrets."alert-mail-password".path}";
      };
    };

    systemd = {
      tmpfiles.rules = [ "d /var/lib/backup-alert 0700 root root -" ];

      services = {
        "backup-failure-notify@" = {
          description = "Mail alert for %i";
          serviceConfig.Type = "oneshot";
          scriptArgs = "%i";
          script = ''
            ${notify} "FAILURE: $1" \
              "$(${pkgs.systemd}/bin/systemctl status "$1" --no-pager -l | head -n 60)

            --- Last logs ---
            $(${pkgs.systemd}/bin/journalctl -u "$1" -n 40 --no-pager)"
          '';
        };

        restic-backups-daily = {
          onFailure = [ "backup-failure-notify@restic-backups-daily.service" ];
          serviceConfig.ExecStartPost = "${pkgs.coreutils}/bin/touch ${stampFile}";
        };

        postgresqlBackup-nextcloud = lib.mkIf enabled.nextcloud {
          onFailure = [ "backup-failure-notify@postgresqlBackup-nextcloud.service" ];
        };
        forgejo-dump = lib.mkIf enabled.git {
          onFailure = [ "backup-failure-notify@forgejo-dump.service" ];
        };
        backup-vaultwarden = lib.mkIf enabled.vault {
          onFailure = [ "backup-failure-notify@backup-vaultwarden.service" ];
        };

        backup-watchdog = {
          description = "Check if the last backup was successfull";
          serviceConfig.Type = "oneshot";
          script = ''
            if [ ! -f ${stampFile} ]; then
              ${notify} "Backup failed" \
                "${stampFile} doesn't exist. So the backup wasn't running in the last 24h" exit 0
            fi

            age=$(( $(date +%s) - $(stat -c %Y ${stampFile}) ))
            max=$(( ${toString maxAgeHours} * 3600 ))

            if [ "$age" -gt "$max" ]; then
              ${notify} "Last backup failed (>${toString maxAgeHours}h)" \
                "The last backup successfull was $((age / 3600))h ago (the limit is: ${toString maxAgeHours}h).
            The time may not run, it can be check using : systemctl list-timers restic-backups-daily"
            fi
          '';
        };
      };

      timers.backup-watchdog = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 10:00:00";
          Persistent = true;
        };
      };
    };
  };
}
