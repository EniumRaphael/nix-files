{ inputs, config, pkgs, lib, ... }:

let
	nextcloud = import ./self_host/nextcloud.nix {
		inherit inputs config pkgs lib;
	};
	cfg = config.service.selfhost;
in
{
	imports = [
		nextcloud
	];

	config  = {
		services.nginx = {
			enable = true;
		};
	};
	options.service.selfhost = {
		nextcloud = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable the nextcloud";
		};
	};
}
