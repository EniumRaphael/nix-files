{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

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
    hostName = "nixos-fix";
    firewall.enable = false;
    networkmanager.enable = true;
    wireless.enable = false;
  };

  games = {
    lutris = false;
    steam = {
      enable = true;
      bp = true;
    };
  };

  service = {
    selfhost = {
      htop = true;
      ollama = false;
      mail = true;
      monitor = true;
      nextcloud = true;
    };
    forty_two.irc = true;
    web.portefolio = true;
    server = {
      minecraft = false;
      teamspeak = true;
    };
    bot_discord = {
      master = true;
      bde = false;
      tut = true;
      marty = true;
      ada = true;
      music = false;
      tempvoc = true;
      ticket = true;
    };
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      axel = {
        isNormalUser = true;
        initialPassword = "Feuyllelpb12341234";
        description = "feuylle";
        useDefaultShell = true;
        extraGroups = [
          "networkmanager"
          "plugdev"
          "docker"
        ];
        packages = with pkgs; [
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
      ports = [ 42131 ];
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
