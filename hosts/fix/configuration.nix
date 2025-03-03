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

	games = {
		lutris = true;
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

	security.pam.services = {
		greetd = {
			enableGnomeKeyring = true;
		};
		swaylock = {};
	};

	users = {
		defaultUserShell = pkgs.zsh;
		users = {
			deb = {
				isNormalUser = true;
				initialPassword = "pasadmin1234";
				description = "deb";
				useDefaultShell = true;
				extraGroups = [
					"networkmanager"
					"dialout"
					"docker"
					"video"
				];
				packages = with pkgs; [
					gnome-session
					home-manager
				];
			};
		};
	};

	# Bootloader.
	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
	};

	environment.systemPackages = with pkgs; [
		wine-staging
		lutris
		dxvk
		vkd3d
	];

	programs = {
		hyprland = {
			enable = true;
			xwayland.enable = true;
		};
		steam = {
			enable = true;
			gamescopeSession.enable = true;
		};
		gamemode.enable = true;
	};

	services = {
		seatd.enable = true;
		xserver = {
			desktopManager.gnome.enable = true;
			displayManager.gdm.wayland = true;
		};
		dbus.enable = true;
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
					command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --user-menu --remember-user-session --time";
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
