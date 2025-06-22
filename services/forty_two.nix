{ config, pkgs, lib, ... }:

let
	irc = import ./forty_two/irc.nix {
		inherit config pkgs lib;
	};
	cfg = config.service.forty_two;
in
{
	imports = [
		irc
	];

	options.service.forty_two = {
		irc = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable the ft_irc server";
		};
	};
}
