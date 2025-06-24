{ inputs, config, pkgs, lib, ... }:

let
	monitor = import ./self_host/monitor.nix {
		inherit inputs config pkgs lib;
	};
	nextcloud = import ./self_host/nextcloud.nix {
		inherit inputs config pkgs lib;
	};
	cfg = config.service.selfhost;
in
{
	imports = [
		nextcloud
		monitor
	];

	config  = {
		services.nginx = {
			enable = true;
		};
	};
	options.service.selfhost = {
		monitor = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable the monitor";
		};
		nextcloud = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable the nextcloud";
		};
	};
}
