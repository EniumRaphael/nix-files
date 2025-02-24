{ config, pkgs, lib, ... }:

let
	lutris = import ./lutris.nix {
		inherit config pkgs lib;
	};
	cfg = config.games;
in
{
	imports = [
		lutris
	];

	options.games = {
		lutris = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable lutris";
		};
	};
}
