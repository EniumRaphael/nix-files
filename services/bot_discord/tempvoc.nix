{ config, pkgs, lib, ... }:

let
	cfg = config.service.bot_discord.tempvoc;
in
{
	config = lib.mkIf cfg {
		environment.systemPackages = with pkgs; [
			nodejs
		];
		users = {
			groups.dsc_tempvoc = {
				name = "dsc_tempvoc";
			};
			users.dsc_tempvoc = {
				description = "Utilisateur pour le bot tempvoc";
				group = "dsc_tempvoc";
				home = "/opt/tempvoc";
				isSystemUser = true;
			};
		};
		systemd.services.tempvoc = {
			description = "Enium discord bot for tempvoc";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "simple";
				User = "dsc_tempvoc";
				WorkingDirectory = "/opt/tempvoc";
				ExecStart = "${pkgs.nodejs}/bin/npm start";
				Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.nodejs}/bin";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
	};
}
