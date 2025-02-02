{ config, pkgs, lib, ... }:

let
	cfg = config.service.bot_discord.master;
in
{
	config = lib.mkIf cfg {
		environment.systemPackages = with pkgs; [
			go
		];
		systemd.services.yagpdb = {
			description = "Enium discord master bot";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "simple";
				User = "nobody";
				WorkingDirectory = "/opt/yagpdb/cmd/yagpdb";
				ExecStart = "/opt/yagpdb/cmd/yagpdb/yagpdb -all -pa";
				EnvironmentFile = "/opt/yagpdb/cmd/yagpdb/sampleenvfile";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
	};
}
