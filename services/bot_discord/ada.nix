{ config, pkgs, lib, ... }:

let
	cfg = config.service.bot_discord.bde;
in
{
	config = lib.mkIf cfg {
		users = {
			groups.dsc_ada = {
				name = "dsc_ada";
			};
			users.dsc_ada = {
				description = "Utilisateur pour le bot Ada";
				group = "dsc_ada";
				home = "/opt/Ada";
				isSystemUser = true;
			};
		};

		systemd.services.bot_ada = {
			description = "Ada (chdoe asso) discord bot public";
			after = [
				"network.target"
			];
			wantedBy = [
				"multi-user.target"
			];
			serviceConfig = {
				Type = "simple";
				User = "dsc_ada";
				WorkingDirectory = "/opt/Ada";
				ExecStart = "/opt/Ada/bot.py";
				EnvironmentFile = "/opt/Ada/.env";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
	};
}
