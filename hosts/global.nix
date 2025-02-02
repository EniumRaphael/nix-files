{ config, pkgs, ... }:

{
	documentation = {
		enable = true;
		man.enable = true;
		dev.enable = true;
	};
	time.timeZone = "Europe/Paris";
	i18n = {
		defaultLocale = "en_US.UTF-8";
		extraLocaleSettings = {
			LC_ADDRESS = "fr_FR.UTF-8";
			LC_IDENTIFICATION = "fr_FR.UTF-8";
			LC_MEASUREMENT = "fr_FR.UTF-8";
			LC_MONETARY = "fr_FR.UTF-8";
			LC_NAME = "fr_FR.UTF-8";
			LC_NUMERIC = "fr_FR.UTF-8";
			LC_PAPER = "fr_FR.UTF-8";
			LC_TELEPHONE = "fr_FR.UTF-8";
			LC_TIME = "fr_FR.UTF-8";
		};
	};
	users = {
		defaultUserShell = pkgs.zsh;
		users = {
			raphael = {
				isNormalUser = true;
				description = "The main account of raphael";
				useDefaultShell = true;
				extraGroups = [
					"networkmanager"
					"dialout"
					"plugdev"
					"wheel"
					"docker"
					"video"
				];
				packages = with pkgs; [
					home-manager
				];
			};
		};
	};
	nixpkgs.config.allowUnfree = true;
	nix.extraOptions = ''experimental-features = nix-command flakes'';
	programs = {
		zsh.enable = true;
	};
	environment.systemPackages = with pkgs; [
		bat
		cairo
		dconf
		fastfetch
		git
		go
		home-manager
		lego
		libjpeg
		libpng
		libuuid
		linux-manual
		man
		man-pages
		man-pages-posix
		networkmanager
		openssl
		pkg-config
		postgresql
		protonup
		python3
		python3Packages.pip
		qflipper
		tmux
		unzip
		wget
		wl-clipboard
		xclip
		xsel
		xdg-desktop-portal-hyprland
		yarn
		zsh
		vim
	];
}
