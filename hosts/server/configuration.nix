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
    ../../modules/games/default.nix
    ../../services/forty_two/default.nix
    ../../services/bot_discord/default.nix
    ../../services/server/default.nix
    ../../services/web/default.nix
    ../../services/self_host/default.nix
    ../../modules/users/default.nix
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
