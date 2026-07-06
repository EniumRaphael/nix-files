{
  config,
  pkgs,
  lib,
  nixName,
  ...
}:

let
  cfg = config.config-sec.autorun;
in
{
  config = lib.mkIf cfg {
    systemd = {
      services.nixos-auto-rebuild = {
        description = "Pull and run the configuration";

        path = [
          pkgs.git
          pkgs.nixos-rebuild
        ];

        script = ''
          set -e
          REPO_DIR="/etc/nixos"

          cd "$REPO_DIR"

          OLD_HASH=$(git rev-parse HEAD)

          git fetch origin
          git reset --hard origin/main

          NEW_HASH=$(git rev-parse HEAD)

          if [ "$OLD_HASH" != "$NEW_HASH" ]; then
            echo "Repo have changed"
            nixos-rebuild switch --flake /etc/nixos#nixos-${nixName}
          else
            echo "No change"
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };

      timers.nixos-auto-rebuild = {
        description = "Set a timer to re-run the nix-configuration each hours";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* *:45:00";
          Persistent = true;
          RandomizedDelaySec = "5min";
        };
      };
    };
  };
}
