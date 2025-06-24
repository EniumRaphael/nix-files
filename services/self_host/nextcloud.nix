{ config, pkgs, lib, ... }:

let
	cfg = config.service.selfhost.nextcloud;
	dataDir = "/mnt/data/nextcloud";
in
{
	environment.systemPackages = with pkgs; [
		php
	];
	services = {
		nextcloud = {
			enable = true;
			https = true;
			package = pkgs.nextcloud31;
			hostName = "nextcloud.enium.eu";
			datadir = "/mnt/data/nextcloud/";
			config = {
				adminpassFile = "/etc/nextcloud-pass.txt";
				adminuser = "OwnedByTheEniumTeam";
				dbtype = "sqlite";
			};
			settings = {
				trusted_domains = [
					"192.168.1.254"
				];
				default_phone_region = "FR";
			};
		};
		nginx.virtualHosts."nextcloud.enium.eu".enableACME = true;
		nginx.virtualHosts."nextcloud.enium.eu".forceSSL = true;
		nginx.virtualHosts."nextcloud.enium.eu".locations."~ \.php$".extraConfig = ''
			fastcgi_pass unix:/run/phpfpm-nextcloud.sock;
		'';
	};
}
