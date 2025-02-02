{ config, pkgs, lib, ... }:

let
	cfg = config.service.bot_discord.music;
in
{
	config = lib.mkIf cfg {
		environment.systemPackages = with pkgs; [
			nodejs
		];
		systemd.services.music = {
			description = "Enium discord bot for music";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "simple";
				User = "nobody";
				WorkingDirectory = "/opt/music";
				ExecStart = "${pkgs.nodejs}/bin/npm start";
				Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.nodejs}/bin";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
	};
}
