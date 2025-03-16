{ inputs, config, pkgs, lib, ... }:

{
	imports = [
		../global.nix
		./hardware-configuration.nix
		../../modules/games/global.nix
		../../services/discord.nix
		../../services/games.nix
	];

	networking = {
		hostName = "nixos-fix";
		firewall.enable = false;
		networkmanager.enable = true;
		wireless.enable = false;
	};

	service = {
		minecraft = {
			enium-pv = true;
		};
		bot_discord = {
			master = true;
			music = true;
			tempvoc = true;
			ticket = true;
		};
	};

	users = {
		defaultUserShell = pkgs.zsh;
	};

	# Bootloader.
	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
	};

	services = {
		seatd.enable = true;
		openssh = {
			enable = true;
			ports = [ 42131 ];
		};
		pipewire = {
			enable = true;
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
			jack.enable = true;
		};
		udev.extraRules = ''
			SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="5740", MODE="0666"
		'';
		redis.servers."" = {
			enable = true;
		};
		postgresql = {
			enable = true;
		};
	};

	virtualisation.docker.enable = true;

	system.stateVersion = "24.05";
}
