{ config, pkgs, lib, ... }:

let
	master_bot = import ./bot_discord/master.nix {
		inherit config pkgs lib;
	};
	music_bot = import ./bot_discord/music.nix {
		inherit config pkgs lib;
	};
	tempvoc_bot = import ./bot_discord/tempvoc.nix {
		inherit config pkgs lib;
	};
	bde_bot = import ./bot_discord/bde.nix {
		inherit config pkgs lib;
	};
	ticket_bot = import ./bot_discord/ticket.nix {
		inherit config pkgs lib;
	};
	cfg = config.service.bot_discord;
in
{
	imports = [
		master_bot
		music_bot
		tempvoc_bot
		ticket_bot
		bde_bot
	];

	options.service.bot_discord = {
		master = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable master bot";
		};
		bde = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable bde bot";
		};
		music = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable music bot";
		};
		tempvoc = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable tempvoc bot";
		};
		ticket = lib.mkOption {
			type = lib.types.bool;
			default = false;
			description = "Enable ticket bot";
		};
	};
}
