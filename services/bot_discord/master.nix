{ config, pkgs, lib, ... }:

let
	cfg = config.service.bot_discord.master;
in
{
	config = lib.mkIf cfg {
		environment.systemPackages = with pkgs; [
			go
		];
		users = {
			groups.dsc_master = {
				name = "dsc_master";
			};
			users.dsc_master = {
				description = "Utilisateur pour le bot master";
				group = "dsc_master";
				home = "/opt/master";
				isSystemUser = true;
			};
		};
		systemd.services.yagpdb = {
			description = "Enium discord master bot";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "simple";
				User = "dsc_master";
				WorkingDirectory = "/opt/yagpdb/cmd/yagpdb";
				ExecStart = "/opt/yagpdb/cmd/yagpdb/yagpdb -all -pa";
				EnvironmentFile = "/opt/yagpdb/cmd/yagpdb/sampleenvfile";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
	};
}
