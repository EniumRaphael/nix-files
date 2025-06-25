{ inputs, config, pkgs, lib, ... }:

let
	htop = import ./self_host/htop.nix {
		inherit inputs config pkgs lib;
	};
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
		htop
		monitor
	];

	config  = {
		services.nginx = {
			enable = true;
		};
	};
	options.service.selfhost = {
		htop = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable the htop";
		};
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
