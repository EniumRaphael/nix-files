{ inputs, config, pkgs, lib, ... }:

let
	enium-pv = import ./games/minecraft.nix {
		inherit inputs config pkgs lib;
	};
	cfg = config.service.minecraft;
in
{
	imports = [
		enium-pv
	];

	options.service.minecraft = {
		enium-pv = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable enium private minecraft server";
		};
	};
}
