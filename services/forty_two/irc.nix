{ config, pkgs, lib, ... }:

let
	cfg = config.service.forty_two.irc;
in
{
	config = lib.mkIf cfg {
		environment.systemPackages = with pkgs; [
			llvmPackages.clang
			llvmPackages.clang-tools
			gnumake
		];
		users = {
			groups.ft_irc = {
				name = "ft_irc";
			};
			users.ft_irc = {
				description = "Utilisateur the ft_irc server";
				group = "ft_irc";
				home = "/opt/irc/";
				isSystemUser = true;
			};
		};

		systemd.services.ft_irc = {
			description = "Upload our irc on my own server";
			after = [
				"network.target"
			];
			wantedBy = [
				"multi-user.target"
			];
			serviceConfig = {
				Type = "simple";
				User = "ft_irc";
				WorkingDirectory = "/opt/irc";
				ExecStartPre = "${pkgs.git}/bin/git pull";
				ExecStart = "/opt/irc/ircserv 4243 irc";
				Restart = "on-failure";
				RestartSec = 30;
				RemainAfterExit = false;
			};
		};
	};
}
