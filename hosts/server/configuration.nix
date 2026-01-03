{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  sshKeyMac = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbHk7YasSMK5FBCArKLeqIoaGXsN+WlgVquObyC5Zec raphael@MacBook-Pro-de-raphael.local";
in
{
  imports = [
    ../global.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ../../modules/games.nix
    ../../services/forty_two.nix
    ../../services/discord.nix
    ../../services/server.nix
    ../../services/web.nix
    ../../services/self_host.nix
  ];

  networking = {
    hostName = "nixos-server";
    firewall.enable = false;
    networkmanager.enable = true;
    interfaces.enp0s31f6.ipv4.addresses = [
      {
        address = "192.168.1.1";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.1.254";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  games = {
    lutris = false;
    steam = {
      enable = false;
      bp = false;
    };
  };

  service = {
    selfhost = {
      htop = true;
      ollama = false;
      mail = true;
      monitor = true;
      nextcloud = true;
      jellyfin = true;
      sso = true;
    };
    forty_two.irc = false;
    web.portefolio = true;
    server = {
      minecraft = true;
      teamspeak = true;
    };
    bot_discord = {
      master = true;
      bde = false;
      tut = false;
      marty = false;
      ada = false;
      music = false;
      tempvoc = false;
      ticket = false;
    };
  };

  environment.systemPackages = with pkgs; [
    age
    bat
    cairo
    dconf
    fastfetch
    git
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
    protonup-ng
    python3
    python3Packages.pip
    qFlipper
    ripgrep
    swaylock
    swaylock-fancy
    tmux
    unzip
    vim
    wget
    wl-clipboard
    xclip
    xdg-desktop-portal-hyprland
    xsel
    yarn
    zsh
  ] ++ [
    inputs.agenix.packages.${pkgs.system}.agenix
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  users.users.raphael.openssh.authorizedKeys.keys = [
    sshKeyMac
  ];
  services = {
    seatd.enable = true;
    xserver = {
      enable = true;
      videoDrivers = [
        "nvidia"
      ];
    };
    dbus.enable = true;
    openssh = {
      enable = true;
      ports = [
	      42131
      ];
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
