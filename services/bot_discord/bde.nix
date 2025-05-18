{ config, pkgs, lib, ... }:

let
	cfg = config.service.bot_discord.bde;
in
{
	config = lib.mkIf cfg {
		users = {
			groups.dsc_bde = {
				name = "dsc_bde";
			};
			users.dsc_bde = {
				description = "Utilisateur pour le bot BDE";
				group = "dsc_bde";
				home = "/opt/bde";
				isSystemUser = true;
			};
		};

		systemd.services.bot_bde = {
			description = "BDE discord bot public";
			after = [
				"network.target"
			];
			wantedBy = [
				"multi-user.target"
			];
			serviceConfig = {
				Type = "simple";
				User = "dsc_bde";
				WorkingDirectory = "/opt/Bde";
				ExecStart = "/opt/Bde/.venv/bin/python /opt/Bde/bot.py";
				EnvironmentFile = "/opt/Bde/.env";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
	};
}
