{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.service.bot_discord.marty;
in
{
  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      nodejs
    ];
    users = {
      groups.dsc_marty = {
        name = "dsc_marty";
      };
      users.dsc_marty = {
        description = "Utilisateur pour le bot BDE";
        group = "dsc_marty";
        home = "/opt/marty";
        isSystemUser = true;
      };
    };

    systemd.services.bot_marty = {
      description = "marty discord bot";
      after = [
        "network.target"
      ];
      wantedBy = [
        "multi-user.target"
      ];
      serviceConfig = {
        Type = "simple";
        User = "dsc_marty";
        WorkingDirectory = "/opt/marty";
        Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.nodejs}/bin";
        ExecStartPre = [
          "${pkgs.nodejs}/bin/npm install"
          "${pkgs.nodejs}/bin/npm run build"
        ];
        ExecStart = "${pkgs.nodejs}/bin/npm run start-prod";
        EnvironmentFile = "/opt/marty/.env";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
