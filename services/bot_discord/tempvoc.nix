{ config, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		nodejs
	];
	systemd.services.ticket = {
		tempvoc = {
			description = "Enium discord bot for tempvoc";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "simple";
				User = "nobody";
				WorkingDirectory = "/root/tempvoc";
				ExecStart = "${pkgs.nodejs}/bin/npm start";
				Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.nodejs}/bin";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
	};
}
