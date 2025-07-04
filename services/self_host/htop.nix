{ config, pkgs, lib, ... }:

let
	cfg = config.service.selfhost.monitor;
in
{
	config = lib.mkIf cfg {
		services = {
			glances.enable = true;

			nginx.virtualHosts."htop.enium.eu" = {
				enableACME = true;
				forceSSL = true;
				locations."/" = {
					proxyPass = "http://127.0.0.1:61208";
					proxyWebsockets = true;
				};
			};
		};
	};
}
