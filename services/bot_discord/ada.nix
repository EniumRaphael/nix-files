{ config, pkgs, lib, ... }:

let
	cfg = config.service.bot_discord.bde;
in
{
	config = lib.mkIf cfg {
		environment.systemPackages = with pkgs; [
			nix
		];
		systemd.services.bot_bde = {
			description = "Ada (chdoe asso) discord bot public";
			after = [
				"network.target"
			];
			wantedBy = [
				"multi-user.target"
			];
			serviceConfig = {
				Type = "simple";
				User = "nobody";
				WorkingDirectory = "/opt/Ada";
				ExecStart = "/opt/Ada/.venv/bin/python /opt/Ada/bot.py";
				EnvironmentFile = "/opt/Ada/.env";
				Restart = "on-failure";
				RestartSec = 5;
				Environment = lib.mkForce''
					Environment=PYTHONUNBUFFERED=1
				'';
			};
		};
	};
}
