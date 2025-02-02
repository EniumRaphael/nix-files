{ config, pkgs, lib, ... }:

let
	cfg = config.service.bot_discord.ticket;
in
{
	config = lib.mkIf cfg {
		environment.systemPackages = with pkgs; [
			nodejs
		];
		systemd.services.ticket = {
			description = "Service for ticket";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "simple";
				User = "nobody";
				WorkingDirectory = "/opt/ticket";
				ExecStart = "${pkgs.nodejs}/bin/npm start";
				Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.nodejs}/bin";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
	};
}
