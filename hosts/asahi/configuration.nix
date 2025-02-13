# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
	imports = [
		../global.nix
		./hardware-configuration.nix
		<apple-silicon-support/apple-silicon-support>
	];

	# Use the systemd-boot EFI boot loader.
	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = false;
	};

	networking = {
		hostName = "nixos-asahi";
		firewall.enable = false;
		networkmanager.enable = true;
	};

	# Set your time zone.
	time.timeZone = "Europe/Paris";

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Select internationalisation properties.
	# i18n.defaultLocale = "en_US.UTF-8";
	# console = {
	#	 font = "Lat2-Terminus32";
	#	 keyMap = "us";
	#	 useXkbConfig = true; # use xkb.options in tty.
	# };

	# Enable the X11 windowing system.
	# services.xserver.enable = true;

	services = {
		pipewire = {
			enable = true;
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
			jack.enable = true;
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
	

	# Configure keymap in X11
	# services.xserver.xkb.layout = "us";
	# services.xserver.xkb.options = "eurosign:e,caps:escape";

	# Enable CUPS to print documents.
	# services.printing.enable = true;

	# Enable sound.
	# services.pulseaudio.enable = true;
	# OR
	# services.pipewire = {
	#	 enable = true;
	#	 pulse.enable = true;
	# };

	# Enable touchpad support (enabled default in most desktopManager).
	# services.libinput.enable = true;

	programs.firefox.enable = true;
	powerManagement.cpuFreqGovernor = "performance";

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	 environment.systemPackages = with pkgs; [
		mesa
		git
		vim
		wget
	 ];

	virtualisation.docker.enable = true;

	xdg.portal = {
		enable = true;
		extraPortals = [
			pkgs.xdg-desktop-portal-hyprland
 		];
		config.common.default = "*";
	};

	system.stateVersion = "25.05"; # Did you read the comment?

}

