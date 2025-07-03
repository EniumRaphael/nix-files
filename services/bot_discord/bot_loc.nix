{ config, pkgs, lib, ... }:

let
	cfg = config.service.bot_discord.tut;
in
{
	config = lib.mkIf cfg {
		users = {
			groups.dsc_loc = {
				name = "dsc_loc";
			};
			users.dsc_loc = {
				description = "Utilisateur pour le bot tut";
				group = "dsc_loc";
				home = "/opt/alerte_poste-master";
				isSystemUser = true;
			};
		};

		systemd.services.bot_loc = {
			description = "loc discord bot public";
			after = [
				"network.target"
			];
			wantedBy = [
				"multi-user.target"
			];
			serviceConfig = {
				Type = "simple";
				User = "dsc_loc";
				WorkingDirectory = "/opt/alerte-poste";
				ExecStart = "/opt/alerte-poste/.venv/bin/python /opt/alerte-poste/src/main.py";
				EnvironmentFile = "/opt/alerte-poste/.env";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
	};
}
