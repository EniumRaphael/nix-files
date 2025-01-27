{ config, pkgs, ... }:

{
	imports = [
		./hardware-configuration.nix
	];

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

	documentation = {
		enable = true;
		man.enable = true;
		dev.enable = true;
	};

	# Set your time zone.
	time.timeZone = "Europe/Paris";

	# Select internationalisation properties.
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

	systemd.services = {
		ticket = {
			description = "Service for ticket";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "simple";
				User = "root";
				WorkingDirectory = "/root/ticket";
				ExecStart = "${pkgs.nodejs}/bin/npm start";
				Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.nodejs}/bin";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
		tempvoc = {
			description = "Service for tempvoc";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "simple";
				User = "root";
				WorkingDirectory = "/root/tempvoc";
				ExecStart = "${pkgs.nodejs}/bin/npm start";
				Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.nodejs}/bin";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
		music = {
			description = "Service for music";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "simple";
				User = "root";
				WorkingDirectory = "/root/music";
				ExecStart = "${pkgs.nodejs}/bin/npm start";
				Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.nodejs}/bin";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
		yagpdb = {
			description = "Service for yagpdb";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "simple";
				User = "root";
				WorkingDirectory = "/root/yagpdb/cmd/yagpdb";
				ExecStart = "/root/yagpdb/cmd/yagpdb/yagpdb -all -pa";
				EnvironmentFile = "/root/yagpdb/cmd/yagpdb/sampleenvfile";
				Restart = "on-failure";
				RestartSec = 5;
			};
		};
	};

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	nix.extraOptions = ''experimental-features = nix-command flakes'';

	programs = {
		zsh.enable = true;
		steam = {
			enable = true;
			gamescopeSession.enable = true;
		};
		gamemode.enable = true;
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
		nodejs
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
		yarn
		zsh
		vim
	];

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
		nginx = {
			virtualHosts = {
				"enium.eu" = {
					forceSSL = true;
					sslCertificate = "/etc/nginx/ssl/selfsigned.crt";
					sslCertificateKey = "/etc/nginx/ssl/selfsigned.key";
				};
			};
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
		xserver.videoDrivers = ["nvidia"];
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
		extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; 
		config.common.default = "*";
	};

	system.stateVersion = "24.05";
}
