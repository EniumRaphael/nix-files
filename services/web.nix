{ inputs, config, pkgs, lib, ... }:

let
	portefolio = import ./web/portefolio.nix {
		inherit inputs config pkgs lib;
	};
	cfg = config.service.web;
in
{
	imports = [
		portefolio
	];

	options.service.web = {
		portefolio = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable the portefolio";
		};
	};
}
