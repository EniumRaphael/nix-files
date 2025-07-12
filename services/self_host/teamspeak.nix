{ config, pkgs, lib, ... }:

let
	cfg = config.service.selfhost.monitor;
in
{
	config = lib.mkIf cfg {
		services = {
			teamspeak3 = {
				enable = true;
			};

			nginx.virtualHosts."ts.enium.eu" = {
				enableACME = true;
				forceSSL = true;
				locations."/" = {
					proxyPass = "http://127.0.0.1:9987";
					proxyWebsockets = true;
				};
			};
		};
	};
}
