{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/games/default.nix
    ../../modules/graphical/default.nix
    ../../modules/hardware/default.nix
    ../../modules/users/default.nix
    ../../modules/applications/default.nix
    ../../services/bot_discord/default.nix
    ../../services/forty_two/default.nix
    ../../services/self_host/default.nix
    ../../services/server/default.nix
    ../../services/web/default.nix
  ];

  config-user = {
    raphael = true;
  };

  graphical = {
    enable = false;
    greetd = false;
    mail = false;
    laptop = false;
  };

  applications = {
    docker = true;
    man = true;
    mullvad = false;
    ssh = true;
  };

  config-hw = {
    network = {
      enable = true;
      wireless = false;
    };
    bluetooth = false;
    fingerprint = false;
    printer = false;
    nix-settings = true;
    nvidia = true;
  };

  games = {
    lutris = false;
    steam = {
      enable = false;
      bp = false;
    };
  };

  networking = {
    hostName = "raphael-server";
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

  service = {
    selfhost = {
      htop = true;
      ollama = false;
      mail = false;
      monitor = true;
      nextcloud = true;
      jellyfin = true;
      sso = true;
      vault = true;
    };
    forty_two.irc = false;
    web.portefolio = true;
    server = {
      minecraft = true;
      teamspeak = true;
    };
    bot_discord = {
      master = false;
      bde = false;
      tut = false;
      marty = false;
      ada = false;
      music = false;
      tempvoc = false;
      ticket = false;
    };
  };

  system.stateVersion = "24.05";
}
