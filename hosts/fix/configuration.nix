{ config, pkgs, lib, ... }:

{
	imports = [
		../global.nix
		./hardware-configuration.nix
		../../services/discord.nix
	];

	service = {
		bot_discord = {
			master = true;
			music = true;
			tempvoc = true;
			ticket = true;
		};
	};

	security.pam.services.swaylock = {};

	# Bootloader.
	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
	};

	networking = {
		hostName = "nixos-fix";
		firewall.enable = false;
		networkmanager.enable = true;
		wireless.enable = false;
	};

	programs = {
		steam = {
			enable = true;
			gamescopeSession.enable = true;
		};
		gamemode.enable = true;
	};

	services = {
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
		greetd = {
			enable = true;
			settings = {
				default_session = {
					command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --remember-user-session --time --cmd Hyprland";
				};
			};
		};
	};

	virtualisation.docker.enable = true;

	xdg.portal = {
		enable = true;
		extraPortals = [
			pkgs.xdg-desktop-portal-hyprland
 		];
		config.common.default = "*";
	};

	system.stateVersion = "24.05";
}
