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
			description = "BDE discord bot public";
			after = [
				"network.target"
			];
			wantedBy = [
				"multi-user.target"
			];
			serviceConfig = {
				Type = "simple";
				User = "nobody";
				WorkingDirectory = "/opt/Bot_Auth";
				ExecStart = "/opt/Bot_Auth/.venv/bin/python /opt/Bot_Auth/bot.py";
				EnvironmentFile = "/opt/Bot_Auth/.env";
				Restart = "on-failure";
				RestartSec = 5;
				Environment = lib.mkForce ''
					Environment=PYTHONUNBUFFERED=1
				'';
			};
		};
	};
}
